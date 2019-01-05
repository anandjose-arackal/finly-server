class AddReferenceToFieldConfigurationInMultiselectSelection < ActiveRecord::Migration[4.2]
  def change
    add_column :field_multiselect_items, :field_configuration_id, :integer, references: "FieldMultiselectItem", foreign_key: true, index: true
    add_column :field_multiselect_selection_items, :field_multiselect_selection_id, :integer, references: "FieldMultiSelectSelection", foreign_key: true, index: true
  end
end
