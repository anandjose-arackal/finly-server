class AddLastMigratedAtToMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    add_column :master_schemas, :last_migration_at, :datetime, index: true
    add_column :master_schemas, :is_table_created, :boolean, default: false
  end
end
