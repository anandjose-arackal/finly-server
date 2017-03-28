class CreatePerDiemExpenses < ActiveRecord::Migration
  def change
    create_table :per_diem_expenses do |t|
      t.references :per_diem, index: true, foreign_key: true
      t.references :expense, index: true, foreign_key: true
      t.integer :quantity
      t.boolean :is_deleted

      t.timestamps null: false
    end
  end
end
