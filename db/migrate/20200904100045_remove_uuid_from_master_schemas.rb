class RemoveUuidFromMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    remove_column :master_schemas, :uuid
    remove_column :master_entities, :uuid
    remove_column :master_entity_choices, :uuid
  end
end
