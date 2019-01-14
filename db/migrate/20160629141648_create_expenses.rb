class CreateExpenses < ActiveRecord::Migration[4.2]
  def change
    create_table :expenses do |t|
      t.references :amount, index: true, foreign_key: true
      t.references :expense_status, index: true, foreign_key: true
      t.text :note
      t.date :date
      t.references :user, index: true, foreign_key: true
      t.references :expense_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
