json.array!(@result.vendors) do |vendor|
  name = vendor.business_name || vendor.name
  json.label name
  json.value vendor.id
end