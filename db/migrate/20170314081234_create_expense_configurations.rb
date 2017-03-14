class CreateExpenseConfigurations < ActiveRecord::Migration
  def change
    create_table :expense_configurations do |t|
      t.boolean :manual_enabled
      t.boolean :card_enabled
      t.boolean :distance_enabled
      t.boolean :time_enabled
      t.boolean :per_diem_enabled
      t.references :configurable, polymorphic: true, null: false

      t.timestamps null: false
    end
  end
end
