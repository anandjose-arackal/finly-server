# Script to update configured_field_value in CustomField records for FieldText and FieldDropDownSelection types

puts "Updating configured_field_value in CustomField records..."

CustomField.where(value_type: ['FieldText', 'FieldDropDownSelection'], configured_field_value: ['', nil]).each do |custom_field|
  custom_field.value&.update_value_in_custom_field
end

puts "Done"
