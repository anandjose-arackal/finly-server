class CreateTimeExpenses < ActiveRecord::Migration[4.2]
  def change
    create_table :time_expenses do |t|
      t.decimal :duration, null: false
      t.string :units, default: "hours", null: false
      t.references :expense, index: true, foreign_key: true
      t.boolean :is_deleted

      t.timestamps null: false
    end
  end
end
