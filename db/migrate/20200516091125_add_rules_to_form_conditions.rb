class AddRulesToFormConditions < ActiveRecord::Migration[5.2]
  def change
    add_column :form_conditions, :rule, :text
    add_column :form_entity_validations, :rule, :text
  end
end
