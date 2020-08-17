class AddLastMigratedAtToMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    add_column :master_schemas, :last_migration_at, :datetime, index: true
  end
end
