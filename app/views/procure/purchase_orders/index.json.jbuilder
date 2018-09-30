json.array! @result.purchase_orders do |po|
  json.extract! po, :id, :po_number, :department_id, :sub_department_id, :cost_center_id
  json.sub_department po.sub_department&.name
  json.created_by po.user&.name
  json.vendor_name po.vendor&.display_name
  json.amount po.balance_amount&.value
  json.procurement_name po.procurement&.name
end