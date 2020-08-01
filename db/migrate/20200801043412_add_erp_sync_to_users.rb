class AddErpSyncToUsers < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(User) rescue nil
  end
end
