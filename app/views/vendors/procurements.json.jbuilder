json.purchase_orders do
  json.array! @result.data[:purchase_orders] do |po|
    json.extract! po, :id, :po_number, :procurement_id
    json.created_by po.user&.name
    json.created_at po.created_at&.strftime("%d-%b-%Y")
    json.amount po.balance_amount&.value
  end
end

json.non_po_invoices do
  json.array! @result.data[:non_po_invoices] do |invoice|
    json.extract! invoice, :id, :invoice_id, :invoice_number, :procurement_id, :invoice_date, :due_date
    json.created_by invoice.created_by&.name
    json.created_at invoice.created_at&.strftime("%d-%b-%Y")
    json.amount invoice.net_amount&.value
  end
end

json.po_invoices do
  json.array! @result.data[:po_invoices] do |invoice|
    json.extract! invoice, :id, :invoice_id, :invoice_number, :procurement_id, :invoice_date, :due_date
    json.created_by invoice.created_by&.name
    json.created_at invoice.created_at&.strftime("%d-%b-%Y")
    json.amount invoice.net_amount&.value
  end
end