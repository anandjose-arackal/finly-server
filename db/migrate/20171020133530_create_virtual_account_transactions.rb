class CreateVirtualAccountTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :virtual_account_transactions do |t|
      t.string :beneficiary_account_number
      t.string :beneficiary_account_ifsc
      t.string :transfer_type
      t.string :beneficiary_full_name
      t.string :transfer_id
      t.string :transfer_timestamp
      t.string :transfer_currency
      t.string :transfer_amount
      t.string :remitter_account_no
      t.string :remitter_account_ifsc
      t.string :remitter_account_type
      t.string :remitter_full_name
      t.string :remitter_address
      t.string :note
      t.string :credited_at

      t.timestamps null: false
    end
  end
end
