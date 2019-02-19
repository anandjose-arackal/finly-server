json.array!(@result.vendors) do |vendor|
  # name = vendor.business_name || vendor.name
  json.vendor_name vendor.name || ""
  json.business_name  vendor.business_name || ""
  json.value vendor.id
end