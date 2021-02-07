class AddEntityTypeToFormCustomField < ActiveRecord::Migration[6.0]
  def change
    add_column :form_custom_fields, :entity_type, :string
  end
end
