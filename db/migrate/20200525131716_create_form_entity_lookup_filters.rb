class CreateFormEntityLookupFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :form_entity_lookup_filters do |t|
      t.uuid :uuid
      t.integer :company_id, index: true, null: false, references: 'companies', foreign_key: true
      t.string :form_id, index: true, null: false
      t.string :form_entity_id, index: true, null: false
      t.string :filter_id, index: true
      t.boolean :custom, index: true
      t.boolean :internal, index: true
      t.boolean :is_updated, index: true
      t.boolean :can_be_updated, index: true
      t.text :rule
      t.integer :created_by_id, index: true, references: 'users', foreign_key: true
      t.integer :updated_by_id, index: true, references: 'users', foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps index: true
    end
  end
end
