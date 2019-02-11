class CreateAutoSyncConfig < ActiveRecord::Migration[4.2]
  def change

    # creating auto sync config types
    create_table :auto_sync_config_types do |t|
      t.string :name

      t.timestamps null: false
    end

    # creating auto sync config tables
    create_table :auto_sync_configs do |t|
      t.references :company, foreign_key: true, index: true
      t.references :auto_sync_config_type, foreign_key: true, index: true
      t.boolean :categories_sync, default: false
      t.boolean :company_tags_sync, default: false
      t.boolean :external_users_sync, default: false
      t.boolean :reports_sync, default: false
      t.references :period, foreign_key: true, index: true
      t.boolean :enabled, default: false

      t.timestamps null: false
    end
  end
end
