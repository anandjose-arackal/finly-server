class AddReceivingAccountToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_reference :virtual_bank_accounts, :receiving_account, polymorphic: true
  end
end