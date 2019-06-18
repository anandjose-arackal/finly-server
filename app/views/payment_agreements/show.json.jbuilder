json.results do
  json.agreement_details do
    json.merge! @result.payment_agreement.as_json
    json.attachments @result.payment_agreement.attachments.as_json
  end

  json.reviewal_chain @result.reviewal_chain

  json.general_invoice_details do
    json.array! @result.general_invoices.each do |general_invoice|
      json.merge! general_invoice.as_json(payment_agreement: true)
      json.invoice_items general_invoice.items.as_json
    end
  end

  json.rental_invoice_details do
    json.array! @result.rental_invoices.each do |rental_invoice|
      json.merge! rental_invoice.as_json(payment_agreement: true)
      json.invoice_items rental_invoice.items.as_json
    end
  end

  json.security_deposit_details do
    json.merge! @result.security_deposits.as_json
  end

  json.beneficiary_payment_details do
    json.merge! @result.beneficiary_payments.as_json(payment_agreement: true)
  end


end