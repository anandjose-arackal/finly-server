class CreateCashExpenseConfigs < ActiveRecord::Migration
  def change
    create_table :cash_expense_configs do |t|
      t.boolean :enabled, default: true
      t.references :policy, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
