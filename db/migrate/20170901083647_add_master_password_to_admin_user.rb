class AddMasterPasswordToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :encrypted_master_password, :string
  end
end
