class RenameValueToNameInChoices < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_entity_choices, :value, :name
  end
end
