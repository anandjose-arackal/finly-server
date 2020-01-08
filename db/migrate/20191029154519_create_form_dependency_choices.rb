class CreateFormDependencyChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :form_dependency_choices do |t|
      t.integer :company_id, references: "Company", index: true, foreign_key: true, null: false
      t.integer :form_dependency_id, references: "form_dependencies", index: true, foreign_key: true, null: false
      t.integer :controlling_choice_id, references: "form_entity_choices", index: true, foreign_key: true, null: false
      t.boolean :is_choice_selected
      t.boolean :dependent_entity_required
      t.boolean :dependent_entity_visible
      t.boolean :dependent_entity_editable

      t.timestamps
    end
  end
end
