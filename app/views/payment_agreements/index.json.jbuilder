json.results do
  json.array!(@result.paginated_payment_agreements) do |payment_agreement|
    json.merge! payment_agreement.as_json_index({})
    if payment_agreement.general_invoices.present?
      json.agreement_type 'general_invoice'
      json.agreement_type_display_name 'General Invoice'
      # json.general_invoices do
      #   json.array!(payment_agreement.general_invoices) do |general_invoice|
      #     json.vendor_name general_invoice&.vendor&.name
      #   end
      # end
    end

    if payment_agreement.rental_invoices.present?
      json.agreement_type 'rental_invoice'
      json.agreement_type_display_name 'Rental Invoice'
      # json.rental_invoices do
      #   json.array!(payment_agreement.rental_invoices) do |rental_invoice|
      #     json.vendor_name rental_invoice&.vendor&.name
      #   end
      # end
    end

    if payment_agreement.beneficiary_payments.present?
      json.agreement_type 'beneficiary_payment'
      json.agreement_type_display_name 'Beneficiary Payment'
      # json.beneficiary_payments do
      #   json.array!(payment_agreement.beneficiary_payments) do |beneficiary_payment|
      #     json.vendor_name beneficiary_payment&.vendor&.name
      #   end
      # end
    end

    if payment_agreement.rental_invoices.blank?
      if payment_agreement.security_deposits.present?
        json.agreement_type 'security_deposit'
        json.agreement_type_display_name 'Security Deposit'
        # json.security_deposits do
        #   json.array!(payment_agreement.security_deposits) do |security_deposit|
        #     json.vendor_name security_deposit&.vendor&.name
        #   end
        # end
      end
    end
  end
end
json.count @result.count