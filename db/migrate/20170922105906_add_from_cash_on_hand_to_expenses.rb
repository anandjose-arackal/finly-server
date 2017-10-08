class AddFromCashOnHandToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :from_cash_on_hand, :boolean
  end
end
