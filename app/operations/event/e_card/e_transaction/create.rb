class Event::ECard::ETransaction::Create < Event::ECard::ETransaction::Base

  def event_id
    NotifierType.id_for(:card_transaction)
  end

  def affected_users
    [self.transaction.user]
  end

  def send_push_notification(user)
    return unless transaction.atm_withdrawal? or transaction.expense?
    param = {}
    param[:transaction_id] = self.transaction.id
    param[:atm_withdrawal] = self.transaction.atm_withdrawal?
    param[:expense] = self.transaction.expense?
    if transaction.expense?
      param[:expense_id] = self.transaction.card_expense.expense_id
      param[:message] = "You have used your Finly Expense Card at #{transaction.card_expense.expense.merchant_name} for of ₹#{transaction.billing_amount.value}"
    elsif transaction.atm_withdrawal?
      param[:message] = "You have withdrawn ₹#{transaction.billing_amount.value} at an ATM"
    end
    param[:event_id] = event_id
    GcmMessenger.push user, param
  end

  def set_notification(user)
    # todo - set notification
  end

  def mailer_subject(user)
    return unless transaction.atm_withdrawal? or transaction.expense?
    if transaction.expense?
      return 'New Card Expense Alert'
    elsif transaction.atm_withdrawal?
      return 'ATM Withdrawal Alert'
    end
    nil
  end

  def mailer_body(user)
    return unless transaction.atm_withdrawal? or transaction.expense?
    if transaction.expense?
      return "This is to inform you that you have used your Finly Expense Card at #{self.transaction.card_expense.expense.merchant_name} for an amount of ₹#{self.transaction.billing_amount.value}"
    elsif transaction.atm_withdrawal?
      return "This is to inform you that an amount of ₹#{self.transaction.billing_amount.value} has been withdrawn through the ATM using Finly Expense Cards"
    end
    nil
  end

end
