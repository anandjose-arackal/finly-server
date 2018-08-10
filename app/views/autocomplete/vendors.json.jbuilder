json.array!(@result.vendors) do |vendor|
  json.label vendor.name
  json.value vendor.id
end