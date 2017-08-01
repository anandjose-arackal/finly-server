class CreateBankTransactions < ActiveRecord::Migration
  def change
    create_table :bank_transfer_statuses do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :bank_transactions do |t|
      t.string :unique_request_number
      t.string :transfer_type
      t.string :bank_reference_number
      t.string :unique_response_number
      t.references :amount, index: true, foreign_key: true
      t.integer :beneficiary_bank_account_id, references: "BankAccount", foreign_key: true, index: true
      t.references :company, index: true, foreign_key: true
      t.integer :transfer_status, references: "BankTransferStatus", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
