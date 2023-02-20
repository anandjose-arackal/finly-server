class AddFormulaFlagInFormEntities < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :can_formula_be_changed, :boolean
  end
end
