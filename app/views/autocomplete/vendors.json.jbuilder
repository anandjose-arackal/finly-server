json.array!(@result.paginated_vendors) do |vendor|
  # name = vendor.business_name || vendor.name
  json.vendor_name vendor.name || ""
  json.business_name  vendor.business_name || ""
  json.trade_name vendor.trade_name || ""
  json.value vendor.id

  if vendor.name.present?
    label = vendor.name
  elsif vendor.business_name.present?
    label = vendor.business_name
  else
    label = ""
  end
  # label = vendor.name || vendor.business_name || ""
  label += " - #{vendor.vendor_id}"
  json.label label
  json.id vendor.id
  json.vendor_code vendor.vendor_id
end