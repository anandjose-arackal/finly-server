class ChangeCustomFieldConfiguredValueType < ActiveRecord::Migration[5.2]
  def change
    remove_index :custom_fields, column: :configured_field_value
    change_column :custom_fields, :configured_field_value, :text
  end
end
