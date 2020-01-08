class AddTransferStatusIdToBbpsYesBankTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_yes_bank_transactions, :transfer_status_id, :integer, references: "BankTransferStatus", foreign_key: true, index: true
    add_column :bbps_yes_bank_transactions, :amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
