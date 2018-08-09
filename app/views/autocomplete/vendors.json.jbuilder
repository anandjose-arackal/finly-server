json.array!(@result.vendors) do |vendor|
  json.id vendor.id
  json.name vendor.name
end