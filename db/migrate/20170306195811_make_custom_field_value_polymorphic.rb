class MakeCustomFieldValuePolymorphic < ActiveRecord::Migration[4.2]
  def change
    remove_column :field_configurations, :default_value
    add_column :field_configurations, :default_value_id, :integer, index: true
    add_column :field_configurations, :default_value_type, :string, index: true

    remove_column :custom_fields, :value
    add_column :custom_fields, :value_id, :integer, index: true
    add_column :custom_fields, :value_type, :string, index: true
  end
end
