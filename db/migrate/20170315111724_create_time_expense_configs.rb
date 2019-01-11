class CreateTimeExpenseConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :time_expense_configs do |t|
      t.references :parent, polymorphic: true
      t.decimal :rate_per_hour

      t.timestamps null: false
    end
  end
end
