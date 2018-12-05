json.result do
  json.array!(@result.paginated_invoices.desc_created) do |invoice|
    json.id invoice.id
    json.invoice_number invoice.invoice_number
    json.date invoice.date
    json.due_date invoice.due_date
    json.customer do
      json.id invoice.customer&.id
      json.name invoice.customer&.name
    end
    json.balance_due invoice.balance_due&.value
    json.total_payable invoice.total_payable&.value
    json.status invoice.invoice_status&.name&.humanize
    json.status_id invoice.invoice_status&.id
    json.invoice_type invoice.outward_invoice_type.name.humanize
  end
end
json.count @result.count