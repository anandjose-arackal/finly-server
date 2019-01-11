class AddReceivingAccountToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_reference :virtual_bank_accounts, :receiving_account, polymorphic: true
  end
end