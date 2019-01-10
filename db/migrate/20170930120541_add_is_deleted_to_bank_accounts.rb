class AddIsDeletedToBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :is_deleted, :boolean, default: false
  end
end
