# Script to update configured_field_value in CustomField records for FieldText and FieldDropDownSelection types

class UpdateConfiguredFieldValueData
  def self.run
    CustomField.where(value_type: 'FieldText', configured_field_value: nil).includes(:value).find_in_batches(batch_size: 1000) do |custom_fields|
      custom_fields.each do |custom_field|
        custom_field.value&.update_value_in_custom_field
      end
    end

    CustomField.where(value_type: 'FieldDropDownSelection', configured_field_value: nil).includes(value: [:value]).find_in_batches(batch_size: 1000) do |custom_fields|
      custom_fields.each do |custom_field|
        custom_field.value&.update_value_in_custom_field
      end
    end

  end
end
