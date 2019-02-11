class CreateManualExpenses < ActiveRecord::Migration[4.2]
  def change
    create_table :manual_expenses do |t|
      t.references :expense, index: true, foreign_key: true
      t.string :merchant

      t.timestamps null: false
    end
  end
end
