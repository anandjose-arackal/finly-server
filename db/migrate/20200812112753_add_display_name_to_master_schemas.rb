class AddDisplayNameToMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    add_column :master_schemas, :primary_entity_key, :string, null: false
    add_column :master_entities, :primary_key, :boolean, index: true
  end
end
