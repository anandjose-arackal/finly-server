json.results do
  json.array!(@result.payment_agreements) do |payment_agreement|
    json.merge! payment_agreement.as_json
    if payment_agreement.general_invoices.present?
      json.general_invoices do
        json.array!(payment_agreement.general_invoices) do |general_invoice|
          json.vendor_name general_invoice&.vendor&.name
          json.agreement_type 'general_invoice'
        end
      end
    end
  end
end