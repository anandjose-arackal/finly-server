class AddConfiguredFieldValueToCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :configured_field_value, :string
    add_index :custom_fields, :configured_field_value
  end
end
