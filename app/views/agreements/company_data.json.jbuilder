json.company_name @result.company.name
json.registered_email @result.email
json.poc_first_name @result.poc_first_name
json.poc_last_name @result.poc_last_name
json.registered_mobile_number @result.registered_mobile_number
json.company_type_id @result.company_type.id
json.street_2 @result.street_2
json.street_3 @result.street_3
json.pin_code @result.pin_code
json.date_of_establishment @result.date_of_establishment

json.company_types do
  json.array!(@result.company_types) do |type|
    json.name type.name
    json.id type.id
  end
end