class CreateKotakBankTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :kotak_bank_transactions do |t|
      t.integer :amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :company_id, references: 'Company', foreign_key: true, index: true
      t.integer :transfer_status_id , references: 'BankTransferStatus', index: true, foreign_key: true
      t.integer :beneficiary_account_id, references: 'BankAccount', foreign_key: true, index: true

      t.string :utr
      t.string :response_status_code
      t.string :unique_reference_number, index: true
      t.string :transfer_type
      t.string :beneficiary_account_number
      t.string :beneficiary_account_ifsc
      t.string :beneficiary_name
      t.string :narration
      t.date :payment_date
      t.timestamps
    end
  end
end
