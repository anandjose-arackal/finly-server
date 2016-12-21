class CreateCardExpenses < ActiveRecord::Migration
  def change
    create_table :card_expenses do |t|
      t.text :editable_merchant
      t.references :card_transaction, index: true, foreign_key: true
      t.references :expense, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
