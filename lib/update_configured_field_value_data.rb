# Script to update configured_field_value in CustomField records for FieldText and FieldDropDownSelection types

class UpdateConfiguredFieldValueData
  def self.run
    puts "Updating configured_field_value in CustomField records..."

    CustomField.where(value_type: ['FieldText', 'FieldDropDownSelection'], configured_field_value: ['', nil]).order(id: 'desc').find_in_batches(batch_size: 1000) do |custom_fields|
      custom_fields.each do |custom_field|
        custom_field.value&.update_value_in_custom_field
      end
    end

    puts "Done"
  end
end
