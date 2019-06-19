json.results do
  json.invoices do
    json.merge! @result.invoices.as_json(payment_history: true)
  end
end