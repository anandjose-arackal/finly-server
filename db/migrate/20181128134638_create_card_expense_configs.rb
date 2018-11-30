class CreateCardExpenseConfigs < ActiveRecord::Migration
  def change
    create_table :card_expense_configs do |t|
      t.boolean :enabled, default: true
      t.references :policy, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
