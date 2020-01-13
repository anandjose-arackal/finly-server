json.results do
  json.invoices do
    if @result.general_invoices.present?
      json.merge! @result.general_invoices.as_json(upcoming_invoices: true) if @result.general_invoices.present?
    end
    if @result.rental_invoices.present?
      json.merge! @result.rental_invoices.as_json(upcoming_invoices: true) if @result.rental_invoices.present?
    end
  end

  json.policies do
    json.array!(@result.policies) do |policy|
      json.id policy.id
      json.name policy.name
    end
  end
end