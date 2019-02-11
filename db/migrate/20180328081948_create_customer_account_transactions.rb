class CreateCustomerAccountTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_account_transactions do |t|
      t.references :customer_account, index: true, foreign_key: true
      t.string :transaction_type
      t.references :virtual_account_transaction, index: {name: "indx_custmer_acc_tranxs_on_virtual_acc_tranx_id"}, foreign_key: true
      t.integer :transaction_amount_id, references: "Amount", index: true, foreign_key: true
      t.string :note

      t.timestamps null: false
    end
  end
end
