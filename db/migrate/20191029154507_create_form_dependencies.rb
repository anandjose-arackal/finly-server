class CreateFormDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :form_dependencies do |t|
      t.integer :company_id, references: "Company", index: true, foreign_key: true, null: false
      t.integer :dependency_type_id, references: "form_dependency_types", index: true, foreign_key: true, null: false
      t.integer :controlling_user_id, references: "users", index: true, foreign_key: true, null: false
      t.integer :controlling_entity_id, references: "form_entities", index: true, foreign_key: true, null: false
      t.integer :dependent_entity_id, references: "form_entities", index: true, foreign_key: true, null: false
      t.integer :created_by_id, references: 'users', index: true, foreign_key: true, null: false
      t.integer :updated_by_id, references: 'users', index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
