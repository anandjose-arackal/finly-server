class CreateManualExpenses < ActiveRecord::Migration
  def change
    create_table :manual_expenses do |t|
      t.references :expense, index: true, foreign_key: true
      t.string :merchant

      t.timestamps null: false
    end
  end
end
