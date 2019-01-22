class MarkExpensesFromCashOnHandAsBeingFromCashPockets < ActiveRecord::Migration[4.2]
  def change
    Expense.where(from_cash_on_hand: true).each do |expense|
      cash_pocket = expense.user.user_pockets.where(user_pocket_type_id: UserPocketType.id_for(:cash)).first
      expense.update(spent_from_id: cash_pocket.id)
    end
  end
end