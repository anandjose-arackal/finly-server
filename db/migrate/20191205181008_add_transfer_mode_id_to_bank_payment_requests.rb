class AddTransferModeIdToBankPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :transfer_mode_id, :integer, foreign_key: true, references: 'TransferModeCompanyMapping'
    add_column :payment_orders, :transfer_mode_id, :integer, foreign_key: true, references: 'TransferModeCompanyMapping'
    add_column :payments, :transfer_mode_id, :integer, foreign_key: true, references: 'TransferModeCompanyMapping'
    add_column :yes_bank_transactions, :transfer_mode_id, :integer, foreign_key: true, references: 'TransferModeCompanyMapping'
    add_column :icici_bank_transactions, :transfer_mode_id, :integer, foreign_key: true, references: 'TransferModeCompanyMapping'

    add_index :bank_payment_requests, :transfer_mode_id
    add_index :payment_orders, :transfer_mode_id
    add_index :payments, :transfer_mode_id
    add_index :yes_bank_transactions, :transfer_mode_id
    add_index :icici_bank_transactions, :transfer_mode_id
  end
end
