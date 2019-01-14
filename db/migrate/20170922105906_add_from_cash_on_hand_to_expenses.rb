class AddFromCashOnHandToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :from_cash_on_hand, :boolean
  end
end
