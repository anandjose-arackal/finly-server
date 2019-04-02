class AddAdminUserToGatekeeperBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :gatekeeper_blocks, :admin_user_id, :integer, references: 'admin_users', index: true, foreign_key: true
  end
end
