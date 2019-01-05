class CreatePerDiemExpenseConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :per_diem_expense_configs do |t|
      t.references :parent, polymorphic: true
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
