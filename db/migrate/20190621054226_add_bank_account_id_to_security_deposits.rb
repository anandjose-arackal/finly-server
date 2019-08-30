class AddBankAccountIdToSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :security_deposits, :bank_account_id, :integer
    add_index :security_deposits, :bank_account_id
  end
end
