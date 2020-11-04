class CreateFormChoiceDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :form_choice_dependencies do |t|
      t.uuid
      t.references :company, index: true, null: false
      t.string :form_id, limit: 36, index: true, null: false
      t.string :form_entity_id, limit: 36, index: true, null: false
      t.string :controlling_entity_id, limit: 36, index: true, null: false
      t.string :dependency_id, index: true
      t.boolean :custom
      t.boolean :is_updated
      t.boolean :can_be_updated

      t.integer :created_by_id, index: true, references: 'users', foreign_key: true
      t.integer :updated_by_id, index: true, references: 'users', foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps index: true, null: false
    end
  end
end
