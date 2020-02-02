json.results do
  json.invoices do
    if @result.paginated_general_invoices.present?
      json.merge! @result.paginated_general_invoices.as_json(upcoming_invoices: true) if @result.paginated_general_invoices.present?
    end
    if @result.paginated_rental_invoices.present?
      json.merge! @result.paginated_rental_invoices.as_json(upcoming_invoices: true) if @result.paginated_rental_invoices.present?
    end
  end

  json.policies do
    json.array!(@result.policies) do |policy|
      json.id policy.id
      json.name policy.name
    end
  end
end