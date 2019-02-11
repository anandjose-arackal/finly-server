class RenameFinlyIntegrationsUsers < ActiveRecord::Migration[4.2]
  def change
    rename_table :finly_integrations_users, :quickbooks_finly_integrations_users
  end
end
