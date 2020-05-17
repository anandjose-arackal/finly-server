class AddRulesToFormConditions < ActiveRecord::Migration[5.2]
  def change
    add_column :form_conditions, :rules, :text
    # add_column :form_validations, :rules, :text
  end
end
