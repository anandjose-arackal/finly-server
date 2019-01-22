class AddCashOnHandDeductedToExpense < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :cash_on_hand_blocked, :boolean
  end
end
