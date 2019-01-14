class MarkAllExistingCashOnHandExpensesAsBlocked < ActiveRecord::Migration[4.2]
  def change
    Expense.spent_from_cash_on_hand.update_all(cash_on_hand_blocked: true)
  end
end