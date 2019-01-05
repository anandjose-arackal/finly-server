class CreateVendorAccountTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_account_transactions do |t|
      t.references :vendor_account, index: true, foreign_key: true
      t.integer :transaction_type_id, references: "TransactionType", foreign_key: true, index: true
      t.references :amount, index: true, foreign_key: true
      t.references :payment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
