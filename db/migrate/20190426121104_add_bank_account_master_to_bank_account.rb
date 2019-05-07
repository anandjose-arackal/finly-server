class AddBankAccountMasterToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :bank_account_master_id, :integer, references: "BankAccountMaster", foreign_key: true, index: true
  end
end
