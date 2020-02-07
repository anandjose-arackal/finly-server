json.results do
  json.invoices do
    # if @result.paginated_general_invoices.present?
    #   json.merge! @result.paginated_general_invoices.as_json(upcoming_invoices: true) if @result.paginated_general_invoices.present?
    # end
    # if @result.paginated_rental_invoices.present?
    #   json.merge! @result.paginated_rental_invoices.as_json(upcoming_invoices: true) if @result.paginated_rental_invoices.present?
    # end

    json.merge! @result.paginated_invoices.as_json(upcoming_invoices: true)
  end

  json.policies do
    json.array!(@result.policies) do |policy|
      json.id policy.id
      json.name policy.name
    end
  end
end

# gi_count = 0
# ri_count = 0

# gi_count = @result.general_invoices.count if @result.general_invoices.present?
# ri_count = @result.rental_invoices.count if @result.rental_invoices.present?

# json.count gi_count + ri_count

json.count = @result.invoices.count
