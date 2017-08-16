class Expense::Personal::Unmark < Expense::Personal::Mark

  attr_accessor :other_category_id, :payment_request

  def init
    super()
  end

  def validate
    unless selected_expense
      add_message :error, "Expense not found"
      return
    end

    unless selected_expense.personal
      add_message :error, "This is not a personal expense"
      return
    end

    unless selected_expense.unreported?
      add_message :error, "This expense cannot be edited at this stage"
      return
    end

    if selected_expense.card_expense?
      if selected_expense.user.cash_in_hand&.balance_value < selected_expense.amount_value
        add_message :error, "You do not have enough cash on hand to unmark this expense as personal"
      end
    end
  end

  def process
    unless selected_expense.update(personal: false)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    # if the expense is a card expense add the amount to cash on hand
    if selected_expense.card_expense?
      # add the amount to cash on hand
      self.payment_request = PaymentRequest.(user, nil, CashOnHand.name, :debit, :personal_expense)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, user.cash_on_hand, selected_expense.amount_value))
      op = AccountManager::Payments::PaymentProcessor.(user, payment_request: self.payment_request)
      unless op.success?
        add_message :error, op.messages[:error]
        selected_expense.update(personal: true)
        return
      end
    end
    add_message :success, 'Expense unmarked as personal'
  end
end