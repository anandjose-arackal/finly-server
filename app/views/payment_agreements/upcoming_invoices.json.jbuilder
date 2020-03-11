json.results do
  json.invoices do
    # if @result.general_invoices.present?
    #   json.merge! @result.general_invoices.as_json(upcoming_invoices: true) if @result.general_invoices.present?
    # end
    # if @result.rental_invoices.present?
    #   json.merge! @result.rental_invoices.as_json(upcoming_invoices: true) if @result.rental_invoices.present?
    # end

    if @result.paginated_general_invoices.present?
      json.merge! @result.paginated_general_invoices.as_json(upcoming_invoices: true) if @result.paginated_general_invoices.present?
    end
    if @result.paginated_rental_invoices.present?
      json.merge! @result.paginated_rental_invoices.as_json(upcoming_invoices: true) if @result.paginated_rental_invoices.present?
    end
    # if @result.beneficiary_payments.present?
    #   json.merge! @result.beneficiary_payments.as_json(payment_agreement: true)
    # end
    # if @result.security_deposits.present?
    #   json.merge! @result.security_deposits.as_json(upcoming_payments: true)
    # end
  end

  json.policies do
    json.array!(@result.policies) do |policy|
      json.id policy.id
      json.name policy.name
    end
  end
end