class CreateFormChoiceDependencyMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :form_choice_dependency_mappings do |t|
      t.string :dependency_id, limit: 36, index: true, null: false
      t.string :form_rule_id, limit: 36, index: true, null: false
      t.string :form_entity_choice_id, limit: 36, index: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps index: true, null: false
    end
  end
end
