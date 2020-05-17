class AddComputationToFormEntity < ActiveRecord::Migration[5.2]
  def change
    FormRuleType.seed_data
    create_table :form_entity_computation_types do |t|
      t.string :name, index: true

      t.datetime :deleted_at, index: true
      t.timestamps index: true
    end
    FormEntityComputationType.seed_data
    add_column :form_entities, :compute_enabled, :boolean
    add_column :form_entities, :compute_type_id, :integer, index: true
    add_column :form_entities, :compute_lookup_entity_path, :string
    add_column :form_entities, :compute_formula, :string, index: true
  end
end
