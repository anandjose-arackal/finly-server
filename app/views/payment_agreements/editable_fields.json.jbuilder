json.results do
  json.fields_config do
    json.payment_agreement @result.payment_agreement_editable_fields
    json.general_invoice @result.general_invoice_editable_fields
    json.rental_invoice @result.rental_invoice_editable_fields
    json.beneficiary_payment @result.security_deposit_editable_fields
    json.security_deposit @result.beneficiary_payment_editable_fields
  end
end