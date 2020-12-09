json.result do
  json.merge! record.as_json(options = {})

  invoice =  record.invoice
  if invoice.present?
    json.invoice_id invoice.invoice_id
    json.invoice_number invoice.invoice_number
    json.invoice_narration invoice.narration
    join.invoice_date invoice.date
  end
end
