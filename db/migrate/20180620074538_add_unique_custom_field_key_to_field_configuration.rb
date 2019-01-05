class AddUniqueCustomFieldKeyToFieldConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :field_key, :string, index: true
    add_column :custom_fields, :field_key, :string, index: true
  end
end
