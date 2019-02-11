class AddMasterPasswordToAdminUser < ActiveRecord::Migration[4.2]
  def change
    add_column :admin_users, :encrypted_master_password, :string
  end
end
