json.results do
  json.agreement_details do
    json.merge! @result.payment_agreement.as_json
  end

  json.reviewal_chain @result.reviewal_chain

  json.general_invoice_details do
    json.merge! @result.general_invoices.as_json
  end

  json.rental_invoice_details
    json.merge! @result.rental_invoices.as_json
  end

  json.security_deposit_details do
    json.merge! @result.security_deposits.as_json
  end

  json.beneficiary_payment_details do
    json.merge! @result.beneficiary_payments.as_json
  end
end