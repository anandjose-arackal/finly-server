class Expense::Cancelled::Unmark < Expense::Cancelled::Mark

  attr_accessor :associated_cancelled_transactions

  def init
    id = params[:id] || params[:expense_id]
    # because the expense will always belong to a particular user
    self.selected_expense = user.expenses.only_card_expenses.find_by(id: id)
    self.associated_cancelled_transactions = selected_expense.card_expense.cancelled_against_transactions rescue nil
  end

  def validate
    unless selected_expense
      add_message :error, "Expense not found"
      return
    end

    unless selected_expense.card_expense?
      add_message :error, "Only card expenses can be cancelled"
      return
    end

    unless selected_expense.card_expense.cancelled
      add_message :error, "This expense has not been cancelled yet"
    end
  end

  def process
    if selected_expense.card_expense.update(cancelled: false)
      associated_cancelled_transactions.update_all(cancelled: false)
      original_amount = selected_expense.amount_value
      cancelled_amount = associated_cancelled_transactions.joins(:billing_amount).sum(:value)
      selected_expense.amount.update(value: (original_amount + cancelled_amount))
    else
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    associated_cancelled_transactions.each do |trans|
      trans.update(cancelled_against_expense_id: nil)
    end

    add_message :success, "Expnse un-cancelled"
  end
end