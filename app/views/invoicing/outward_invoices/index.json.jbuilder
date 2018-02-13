json.array!(@result.paginated_invoices) do |invoice|
  json.id invoice.id
  json.invoice_number invoice.invoice_number
  json.date invoice.date
  json.due_date invoice.due_date
  json.customer do
    json.id invoice.customer&.id
    json.name invoice.customer&.name
  end
  json.balance_due invoice.balance_due&.value
  json.status invoice.invoice_status&.name&.humanize
end