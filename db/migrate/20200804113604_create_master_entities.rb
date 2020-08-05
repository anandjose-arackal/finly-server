class CreateMasterEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :master_entities do |t|
      t.uuid
      t.string :master_schema_id, index: true, null: false
      t.string :parent_id, index: true
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.string :type, index: true, null: false
      t.string :hint
      t.boolean :required
      t.boolean :unique
      t.string :position
      t.string :entity_key, index: true, null: false
      t.boolean :system_entity, index: true, default: false
      t.string :label, null: false
      t.string :active, index: true
      t.boolean :can_label_be_changed
      t.boolean :can_uniqueness_be_changed
      t.boolean :can_mandatory_be_changed
      t.boolean :can_active_be_changed
      t.boolean :can_be_destroyed
      t.boolean :show_in_lookup
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
