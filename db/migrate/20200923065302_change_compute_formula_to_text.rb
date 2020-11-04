class ChangeComputeFormulaToText < ActiveRecord::Migration[5.2]
  def change
    change_column :form_entities, :compute_formula, :text
  end
end
