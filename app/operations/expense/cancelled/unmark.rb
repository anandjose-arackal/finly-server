class Expense::Cancelled::Unmark < Expense::Cancelled::Mark

  attr_accessor :associated_cancelled_transactions

  def init
    id = params[:id] || params[:expense_id]
    # because the expense will always belong to a particular user
    self.selected_expense = user.expenses.find_by(id: id)
    self.associated_cancelled_transactions = selected_expense.cancelled_against_transactions
  end
end