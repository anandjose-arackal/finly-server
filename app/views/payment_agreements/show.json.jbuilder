json.results do
  json.agreement_details do
    json.merge! @result.payment_agreement.as_json
  end

  json.reviewal_chain @result.reviewal_chain

  json.general_invoice_details do
    json.array! @result.general_invoices.each do |general_invoice|
      json.merge! general_invoice.as_json
      json.vendor_details general_invoice.vendor.as_json
      json.department_details general_invoice.department.as_json
      json.location_details general_invoice.location.as_json
      json.cost_center_details general_invoice.cost_center.as_json
      json.vendor_location_details general_invoice.gstin_location.as_json
    end
  end

  json.rental_invoice_details do
    json.merge! @result.rental_invoices.as_json
  end

  json.security_deposit_details do
    json.merge! @result.security_deposits.as_json
  end

  json.beneficiary_payment_details do
    json.merge! @result.beneficiary_payments.as_json
  end


end