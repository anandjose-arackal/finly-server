class UpdateCustomFieldDataType < ActiveRecord::Migration[6.0]

  def change
    remove_index :form_custom_fields, :value
    change_column :form_custom_fields, :value, :text, limit: 65535
  end
end
