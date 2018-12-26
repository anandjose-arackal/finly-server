# action that recomputes settlement once a report has been approved
# the user passed must be the report owner, NOT person approving it.
# params:
# report: report being marked as approved
#

class Settlement::SReport::Approved < Reports::Base
  attr_accessor :report

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve])
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Report not found'
      return
    end
    if user.blank? and not params[:auto_approve]
      add_message :error, 'User not found'
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    if report.accounted?
      messages[:error] << 'Report has already been accounted for'
    end
  end

  def process
    ############### Performing balance sheet calculations for the given report's total ###########
    balance_sheet = report.user.balance_sheet
    total_reimbursable_amount = report.total_amount(:reimbursable)

    total_card_amount = report.total_amount(:only_card_expenses)

    total_non_reimbursable_amount = report.total_amount(:non_reimbursable) - total_card_amount

    currency = Currency.first
    balance_sheet.add_approved_reports_total total_reimbursable_amount, currency

    # adding report's total reimbursable amount
    if report.reimbursable_expenses_total.blank?
      reimbursable_amount = Amount.new(value: total_reimbursable_amount, currency: Currency.first)
      unless reimbursable_amount.save
        messages[:error] = reimbursable_amount.errors.full_messages
        return
      end
      unless report.update_attributes(reimbursable_expenses_total: reimbursable_amount)
        messages[:error] = report.errors.full_messages
        return
      end
    else
      unless report.reimbursable_expenses_total.update_attributes(value: total_reimbursable_amount, currency: Currency.first)
        messages[:error] = report.errors.full_messages
        return
      end
    end

    # adding report's total non reimbursable amount
    if report.non_reimbursable_expenses_total.blank?
      non_reimbursable_amount = Amount.new(value: total_non_reimbursable_amount, currency: Currency.first)
      unless non_reimbursable_amount.save
        messages[:error] = non_reimbursable_amount.errors.full_messages
        return
      end
      unless report.update_attributes(non_reimbursable_expenses_total: non_reimbursable_amount)
        messages[:error] = report.errors.full_messages
        return
      end
    else
      unless report.non_reimbursable_expenses_total.update_attributes(value: total_non_reimbursable_amount, currency: Currency.first)
        messages[:error] = report.errors.full_messages
        return
      end
    end

    # adding reports total card amount
    if report.card_expenses_total.blank?
      card_amount = Amount.new(value: total_card_amount, currency: Currency.first)
      unless card_amount.save
        messages[:error] = card_amount.errors.full_messages
        return
      end
      unless report.update_attributes(card_expenses_total: card_amount)
        messages[:error] = report.errors.full_messages
        return
      end
    else
      unless report.card_expenses_total.update_attributes(value: total_card_amount, currency: Currency.first)
        messages[:error] = report.errors.full_messages
        return
      end
    end
    ################################## End of balance sheet calculations ##############################

    unless report.save
      messages[:error] = report.errors.full_messages
    end

    ########### Cash Pocket Deductions ###############

    user_pocket_ids = report.expenses.pluck(:spent_from_id).uniq
    cash_pockets = report.user.user_pockets.cash_pockets_only.with_id(user_pocket_ids)
    cash_pockets.each do |pocket|
      deduction = self.report.expenses.with_spent_from_id(pocket.id).joins(:amount).sum(pocket.base_currency&.country_code)
      if deduction.present? && deduction > 0
        payment_request = PaymentRequest.(self.report.user, nil, "UserPocket", :debit, :settlement_against_advance)
        payment_request.add_payment_item(PaymentRequest::PaymentItem.(self.report.user, pocket, deduction))
        op = AccountManager::Payments::PaymentProcessor.(self.report.user, payment_request: payment_request)
        if op.success?
          payment = op.payment_order.payments.first
          payment.update(reference_resource: self.report)
        else
          # add a condition here so that if this fails, we are notified or at least initimated in some way

        end
      end
    end

    ########### end of cash pocket deductions ########
  end

  def post_process
    # marking the report as accounted for
    report.update(accounted: true)
  end

  def success
    report
  end

end