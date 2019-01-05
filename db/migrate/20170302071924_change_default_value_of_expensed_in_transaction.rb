class ChangeDefaultValueOfExpensedInTransaction < ActiveRecord::Migration[4.2]
  def change
    change_column_default :card_transactions, :expensed, false
  end
end
