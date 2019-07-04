class CreateIciciStatements < ActiveRecord::Migration[5.2]
  def change
    create_table :icici_statements do |t|
      t.string :cheque_no
      t.datetime :txn_date
      t.decimal :amount, precision: 10, scale: 5
      t.decimal :balance, precision: 10, scale: 5
      t.datetime :value_date
      t.string :type
      t.string :transaction_id
      t.string :request_id
      t.integer :bank_transaction_id, references: "IciciBankTransaction"

      t.timestamps
    end
  end
end
