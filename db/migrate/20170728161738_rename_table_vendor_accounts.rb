class RenameTableVendorAccounts < ActiveRecord::Migration
  def change
    rename_table :vendor_accounts, :bank_accounts
  end
end
