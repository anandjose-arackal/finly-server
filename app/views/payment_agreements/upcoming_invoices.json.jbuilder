json.results do
  json.invoices do
    json.merge! @result.invoices.as_json(upcoming_invoices: true)
  end
end