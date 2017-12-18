class MarkAllExistingCashOnHandExpensesAsBlocked < ActiveRecord::Migration
  def change
    Expense.spent_from_cash_on_hand.update_all(cash_on_hand_blocked: true)
  end
end