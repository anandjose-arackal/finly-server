# json.purchase_orders do
#   json.array! @result.data[:purchase_orders] do |po|
#     json.extract! po, :id, :po_number, :procurement_id
#     json.created_by po.user&.name
#     json.created_at po.created_at&.strftime("%d-%b-%Y")
#     json.amount po.balance_amount&.value
#   end
# end

# json.po_invoices do
#   json.array! @result.data[:po_invoices] do |invoice|
#     json.extract! invoice, :id, :invoice_id, :invoice_number, :procurement_id, :date, :due_date
#     json.created_by invoice.created_by&.name
#     json.created_at invoice.created_at&.strftime("%d-%b-%Y")
#     json.amount invoice.net_amount&.value
#   end
# end

json.documents do
  json.array! @result.paginated_documents do |document|
    json.extract! document, :id, :procurement_id

    case document.class.name
    when 'Invoice'
      json.document_number document.invoice_number
      json.date document.date
      json.due_date document.due_date
      json.created_by document.created_by&.name
      json.created_at document.created_at&.strftime("%d-%b-%Y")
      json.amount document.net_amount&.value
    when 'PurchaseOrder'
      json.document_number document.po_number
      json.date document.delivery_date
      json.created_by document.user&.name
      json.created_at document.created_at&.strftime("%d-%b-%Y")
      json.amount document.balance_amount&.value
    end

  end
end

json.count @result.documents.count