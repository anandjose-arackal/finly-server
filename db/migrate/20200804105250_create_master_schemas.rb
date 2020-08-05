class CreateMasterSchemas < ActiveRecord::Migration[5.2]
  def change
    create_table :master_schemas do |t|
      t.uuid
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.string :name, index: true, null: false
      t.string :table_name, index: true, null: false
      t.string :model
      t.string :klass_name
      t.boolean :active, index: true, default: true
      t.boolean :system_master, index: true
      t.boolean :can_name_be_changed
      t.boolean :can_attributes_be_nested
      t.boolean :can_attributes_be_changed
      t.datetime :deleted_at, index: true
      t.integer :owner_id, index: true, references: 'users', foreign_key: true

      t.timestamps index: true
    end
  end
end