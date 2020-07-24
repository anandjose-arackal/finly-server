# Script to update configured_field_value in CustomField records for FieldText and FieldDropDownSelection types

class UpdateConfiguredFieldValueData
  def self.run
    CustomField.where(value_type: 'FieldText', configured_field_value: nil).includes(:value).find_in_batches(batch_size: 1000) do |custom_fields|
      custom_fields.each do |custom_field|
        custom_field.configured_field_value = custom_field.value&.value
      end
      CustomField.import custom_fields, on_duplicate_key_update: [:configured_field_value]
    end

    CustomField.where(value_type: 'FieldDropDownSelection', configured_field_value: nil).includes(value: [:value]).find_in_batches(batch_size: 1000) do |custom_fields|
      custom_fields.each do |custom_field|
        custom_field.configured_field_value = custom_field.value&.value&.name
      end
      CustomField.import custom_fields, on_duplicate_key_update: [:configured_field_value]
    end

  end
end
