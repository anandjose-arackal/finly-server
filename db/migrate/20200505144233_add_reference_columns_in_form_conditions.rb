class AddReferenceColumnsInFormConditions < ActiveRecord::Migration[5.2]
  def change
    add_column :form_conditions, :condition_id, :string, index: true
    add_column :form_conditions, :custom, :boolean, index: true
    add_column :form_conditions, :internal, :boolean, index: true
    add_column :form_conditions, :is_updated, :boolean
    add_column :form_conditions, :can_be_updated, :boolean

    add_column :form_entity_validations, :validation_id, :string, index: true
    add_column :form_entity_validations, :custom, :boolean, index: true
    add_column :form_entity_validations, :internal, :boolean, index: true
    add_column :form_entity_validations, :is_updated, :boolean
    add_column :form_entity_validations, :can_be_updated, :boolean
  end
end
