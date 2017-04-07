class ChangeDefaultValueOfExpensedInTransaction < ActiveRecord::Migration
  def change
    change_column_default :card_transactions, :expensed, false
  end
end
