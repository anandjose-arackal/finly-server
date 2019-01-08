class RenameColumnNamesInUserDelegateMappings < ActiveRecord::Migration
  def change
    rename_column :user_delegate_mappings, :trip_create, :travel_request_create
    rename_column :user_delegate_mappings, :trip_update, :travel_request_update
    rename_column :user_delegate_mappings, :trip_submit, :travel_request_submit
    rename_column :user_delegate_mappings, :trip_retract, :travel_request_retract    
  end
end
