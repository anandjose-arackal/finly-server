class CreateTranscribedExpenses < ActiveRecord::Migration[4.2]
  def change
    create_table :transcribed_expenses do |t|
      t.references :amount, index: true, foreign_key: true
      t.date :date
      t.text :merchant
      t.text :note
      t.references :receipt, index: true, foreign_key: true
      t.references :expense, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
