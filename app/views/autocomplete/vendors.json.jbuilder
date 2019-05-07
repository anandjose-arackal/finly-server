json.array!(@result.vendors) do |vendor|
  # name = vendor.business_name || vendor.name
  json.vendor_name vendor.name || ""
  json.business_name  vendor.business_name || ""
  json.value vendor.id

  label = vendor.name || vendor.business_name || ""
  label += " - #{vendor.vendor_id}"
  json.label label
  json.id vendor.id
  json.vendor_code vendor.vendor_id
end