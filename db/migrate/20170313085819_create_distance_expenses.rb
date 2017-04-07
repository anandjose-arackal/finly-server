class CreateDistanceExpenses < ActiveRecord::Migration
  def change
    create_table :distance_expenses do |t|
      t.references :expense, index: true, foreign_key: true
      t.decimal :distance, null: false
      t.string :unit, null: false, default: "KM"
      t.boolean :is_deleted, default: false

      t.timestamps null: false
    end
  end
end
