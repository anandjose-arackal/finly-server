json.array! @result.purchase_orders do |po|
  json.extract! po, :id, :department, :sub_department, :cost_center,:template_name
  json.vendor do
    json.name po.vendor&.name
    json.business_name po.vendor&.business_name
  end
  json.created_on DateUtils.date_formatted(po.created_at)
end