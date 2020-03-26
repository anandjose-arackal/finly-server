json.results do
  json.invoices do
    # json.merge! @result.invoices.as_json(payment_history: true)
    json.merge! @result.paginated_invoices.as_json(payment_history: true)
  end

  # FE wants it inside result obj
  json.count @result.invoices.count
end