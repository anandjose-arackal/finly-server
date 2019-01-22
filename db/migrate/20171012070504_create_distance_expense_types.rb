class CreateDistanceExpenseTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :distance_expense_types do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    DistanceExpenseType.seed_data
    add_column :distance_expenses, :type_id, :integer, references: 'DistanceExpenseType', index: true, foreign_key: true
    DistanceExpense.all.update_all(type_id: DistanceExpenseType.id_for(:distance))
  end
end
