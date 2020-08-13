class AddDisplayNameToMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Migration.add_column :master_schemas, :primary_entity_key, :string, null: false
    ActiveRecord::Migration.add_column :master_entities, :primary_key, :boolean, index: true
  end
end
