json.merge! record.as_json(macro: true)
invoice =  record.invoice
if invoice.present?
  json.invoice_id invoice.invoice_id
  json.invoice_number invoice.invoice_number
  json.invoice_narration invoice.narration
  json.invoice_date invoice.date
end

