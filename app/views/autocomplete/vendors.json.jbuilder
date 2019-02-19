json.array!(@result.vendors) do |vendor|
  # name = vendor.business_name || vendor.name
  json.vendor_name vendor.name rescue nil
  json.business_name  vendor.business_name rescue nil
  json.value vendor.id
end