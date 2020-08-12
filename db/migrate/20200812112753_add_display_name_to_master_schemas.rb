class AddDisplayNameToMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    add_column :master_schemas, :display_name, :text, null: false
  end
end
