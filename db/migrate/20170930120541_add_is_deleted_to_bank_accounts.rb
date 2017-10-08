class AddIsDeletedToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :is_deleted, :boolean, default: false
  end
end
