class CreateDistanceExpenseConfigs < ActiveRecord::Migration
  def change
    create_table :distance_expense_configs do |t|
      t.references :parent, polymorphic: true
      t.decimal :rate_per_km

      t.timestamps null: false
    end
  end
end
