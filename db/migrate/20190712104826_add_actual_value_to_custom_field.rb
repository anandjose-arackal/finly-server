class AddActualValueToCustomField < ActiveRecord::Migration[5.2]
  def change
    CustomField.find_each do |custom_field|
      case custom_field.field_configuration.field_type_id
      when FieldType.id_for(:text)
        custom_field.update_column('configured_field_value', custom_field.try(:value).try(:value))
      when FieldType.id_for(:dropdown)
        custom_field.update_column('configured_field_value', custom_field.try(:value).try(:value).try(:name))
      end
    end
  end
end
