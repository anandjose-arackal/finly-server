json.array!(@result.vendors) do |vendor|
  json.label vendor.id
  json.value vendor.name
end
