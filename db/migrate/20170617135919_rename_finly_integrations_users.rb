class RenameFinlyIntegrationsUsers < ActiveRecord::Migration
  def change
    rename_table :finly_integrations_users, :quickbooks_finly_integrations_users
  end
end
