class CreateMasterMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :master_mappings do |t|
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.integer :created_by_id, references: "users", index: true, foreign_key: true
      
      t.integer :master_entity_id, index: true, null: false
      t.integer :from_record_id, polymorphic: true
      t.string :from_record_type, polymorphic: true
      t.integer :to_record_id, polymorphic: true
      t.string :to_record_type, polymorphic: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
