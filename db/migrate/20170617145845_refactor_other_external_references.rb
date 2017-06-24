class RefactorOtherExternalReferences < ActiveRecord::Migration
  def change
    rename_column :users, :external_id, :quickbooks_id
    rename_column :users, :external_additional_information, :quickbooks_additional_information
    rename_column :users, :external_updated_at, :quickbooks_updated_at
    rename_column :users, :external_integration_type, :quickbooks_integration_type

    rename_column :quickbooks_finly_integrations_users, :external_additional_information, :quickbooks_additional_information
  end
end
