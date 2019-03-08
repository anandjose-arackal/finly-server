# action that recomputes settlement once a money_request has been approved
# the user passed must be the money_request owner, NOT person approving it.
# params:
# money_request: money_request being marked as approved
#

class Settlement::SMoneyRequests::Approved < MoneyRequests::Base
  attr_accessor :money_request

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve])
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'MoneyRequest not found'
      return
    end
    if user.blank? and not params[:auto_approve]
      add_message :error, 'User not found'
    end
  end

  def init
    self.money_request = params[:money_request]
  end

  def validate
    if money_request.accounted?
      messages[:error] << 'MoneyRequest has already been accounted for'
    end
  end

  def process
    ############### Performing balance sheet calculations for the given money_request's total ###########
    balance_sheet = money_request.user.balance_sheet
    total_reimbursable_amount = money_request.total_amount(:reimbursable)

    total_card_amount = money_request.total_amount(:only_card_expenses)

    total_non_reimbursable_amount = money_request.total_amount(:non_reimbursable) - total_card_amount

    currency = Currency.first
    balance_sheet.add_approved_money_requests_total total_reimbursable_amount, currency

    # adding money_request's total reimbursable amount
    if money_request.reimbursable_expenses_total.blank?
      reimbursable_amount = Amount.new(value: total_reimbursable_amount, currency: Currency.first)
      unless reimbursable_amount.save
        messages[:error] = reimbursable_amount.errors.full_messages
        return
      end
      unless money_request.update_attributes(reimbursable_expenses_total: reimbursable_amount)
        messages[:error] = money_request.errors.full_messages
        return
      end
    else
      unless money_request.reimbursable_expenses_total.update_attributes(value: total_reimbursable_amount, currency: Currency.first)
        messages[:error] = money_request.errors.full_messages
        return
      end
    end

    # adding money_request's total non reimbursable amount
    if money_request.non_reimbursable_expenses_total.blank?
      non_reimbursable_amount = Amount.new(value: total_non_reimbursable_amount, currency: Currency.first)
      unless non_reimbursable_amount.save
        messages[:error] = non_reimbursable_amount.errors.full_messages
        return
      end
      unless money_request.update_attributes(non_reimbursable_expenses_total: non_reimbursable_amount)
        messages[:error] = money_request.errors.full_messages
        return
      end
    else
      unless money_request.non_reimbursable_expenses_total.update_attributes(value: total_non_reimbursable_amount, currency: Currency.first)
        messages[:error] = money_request.errors.full_messages
        return
      end
    end

    # adding money_requests total card amount
    if money_request.card_expenses_total.blank?
      card_amount = Amount.new(value: total_card_amount, currency: Currency.first)
      unless card_amount.save
        messages[:error] = card_amount.errors.full_messages
        return
      end
      unless money_request.update_attributes(card_expenses_total: card_amount)
        messages[:error] = money_request.errors.full_messages
        return
      end
    else
      unless money_request.card_expenses_total.update_attributes(value: total_card_amount, currency: Currency.first)
        messages[:error] = money_request.errors.full_messages
        return
      end
    end
    ################################## End of balance sheet calculations ##############################

    unless money_request.save
      messages[:error] = money_request.errors.full_messages
    end

    ###### Cash on Hand Deductions ###############
    cash_on_hand_deduction = self.money_request.expenses.spent_from_cash_on_hand.joins_amount.sum(:value)
    if cash_on_hand_deduction.present? && cash_on_hand_deduction > 0
      payment_request = PaymentRequest.(self.money_request.user, nil, "CashOnHand", :debit, :settlement_against_cash_on_hand)
      payment_request.add_payment_item(PaymentRequest::PaymentItem.(self.money_request.user, self.money_request.user.cash_on_hand, cash_on_hand_deduction))
      op = AccountManager::Payments::PaymentProcessor.(self.money_request.user, payment_request: payment_request)
      if op.success?
        payment = op.payment_order.payments.first
        payment.update(reference_resource: self.money_request)
      end
    end
    ######### end of cash on hand deduction ########
  end

  def post_process
    # marking the money_request as accounted for
    money_request.update(accounted: true)
  end

  def success
    money_request
  end

end