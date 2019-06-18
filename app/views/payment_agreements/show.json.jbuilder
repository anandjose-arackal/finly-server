json.results do
  json.agreement_details do
    json.merge! @result.payment_agreement.as_json
    json.attachments @result.payment_agreement.attachments.as_json
  end

  json.reviewal_chain @result.reviewal_chain

  json.general_invoice_details do
    json.array! @result.general_invoices.each do |general_invoice|
      json.merge! general_invoice.as_json
      json.invoice_items general_invoice.items.as_json
      json.vendor general_invoice.vendor.as_json
      json.department general_invoice.department.as_json
      json.location general_invoice.location.as_json
      json.cost_center general_invoice.cost_center.as_json
      json.vendor_location general_invoice.vendor_location.as_json
      json.payment_term general_invoice.payment_term.as_json
      json.notify_users general_invoice.notify_users.as_json
      json.billing_type general_invoice.billing_type.as_json
    end
  end

  json.rental_invoice_details do
    json.merge! @result.rental_invoices.as_json
  end

  json.security_deposit_details do
    json.merge! @result.security_deposits.as_json
  end

  json.beneficiary_payment_details do
    json.merge! @result.beneficiary_payments.as_json(payment_agreement: true)
  end


end