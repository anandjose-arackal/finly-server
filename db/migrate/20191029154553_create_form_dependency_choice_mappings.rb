class CreateFormDependencyChoiceMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :form_dependency_choice_mappings do |t|
      t.integer :company_id, references: "Company", index: true, foreign_key: true, null: false
      t.integer :form_dependency_choice_id, references: "form_dependency_choices", index: {name: "index_form_dependency_choice_mappings_form_dependency_choice_id"}, foreign_key: true, null: false
      t.integer :dependent_choice_id, references: "form_entity_choices", index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
