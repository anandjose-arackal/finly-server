class AddCashOnHandDeductedToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :cash_on_hand_blocked, :boolean
  end
end
