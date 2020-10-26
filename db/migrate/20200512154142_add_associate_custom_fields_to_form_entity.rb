class AddAssociateCustomFieldsToFormEntity < ActiveRecord::Migration[5.2]
  def change
    add_column :form_entities, :associate_custom_fields, :boolean, index: true
  end
end