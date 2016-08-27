class CreateCardTransactions < ActiveRecord::Migration
  def change
    create_table :card_transactions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :card, index: true, foreign_key: true
      t.string :channel
      t.string :merchant_category_code
      t.integer :merchant_id
      t.string :merchant_name
      t.string :network
      t.integer :terminal_id
      t.string :trace_number
      t.string :transaction_currency_code
      t.string :transaction_type
      t.string :card_currency_code
      t.text :post_data
      t.string :bank_network
      t.integer :transaction_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :card_amount_id, references: "Amount", foreign_key: true, index: true
      t.datetime :date

      t.timestamps null: false
    end
  end
end
