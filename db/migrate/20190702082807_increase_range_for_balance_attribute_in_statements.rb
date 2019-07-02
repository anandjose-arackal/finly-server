class IncreaseRangeForBalanceAttributeInStatements < ActiveRecord::Migration[5.2]
  def change
    change_column :icici_statements, :balance, :decimal, precision: 20, scale: 10
    change_column :icici_statements, :amount, :decimal, precision: 20, scale: 10
  end
end
