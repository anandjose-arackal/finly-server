json.array! @result.invoices do |invoice|
  json.extract! invoice, :id, :invoice_id, :invoice_number, :department_id, :sub_department_id, :cost_center_id
  json.sub_department invoice.sub_department&.name
  json.created_by invoice.created_by&.name
  json.vendor_name invoice.vendor&.display_name
  json.amount invoice.net_amount&.value
  json.procurement_name invoice.procurement&.name
end