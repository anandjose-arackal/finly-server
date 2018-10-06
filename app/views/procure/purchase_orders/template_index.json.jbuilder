json.array! @result.purchase_orders do |po|
  json.extract! po, :id, :department, :sub_department, :cost_center,:template_name
  json.created_on DateUtils.date_formatted(po.created_at)
end