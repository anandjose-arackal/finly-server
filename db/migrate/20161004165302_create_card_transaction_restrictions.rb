class CreateCardTransactionRestrictions < ActiveRecord::Migration[4.2]
  def change
    create_table :card_transaction_restrictions do |t|
      t.integer :count
      t.references :card, index: true, foreign_key: true
      t.integer :period_id, references: 'Period', index: true, foreign_key: true
      t.references :product_combination, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
