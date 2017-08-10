# action that recomputes settlement once a report has been approved
# the user passed must be the report owner, NOT person approving it.
# params:
# report: report being marked as approved
#

class Settlement::Report::Approved < Report::Base
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

    unless report.save
      messages[:error] = report.errors.full_messages
    end
  end

  def post_process

  end

  def success
    report
  end

end