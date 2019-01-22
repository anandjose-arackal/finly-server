class RenameTableVendorAccounts < ActiveRecord::Migration[4.2]
  def change
    rename_table :vendor_accounts, :bank_accounts
  end
end
