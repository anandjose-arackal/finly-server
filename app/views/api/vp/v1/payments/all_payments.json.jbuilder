json.array!(@result.paginated_payments) do |payment|
  json.id payment.id
  json.beneficiary do
    json.name payment.receiving_user.name
    json.account_number payment.receiving_account&.account_number
    json.ifsc payment.receiving_account&.ifsc
  end
  json.date payment.date.strftime("%Y-%m-%d")
  json.payment_mode payment.payment_mode&.upcase
  json.schedule_at payment.scheduled_at
  json.processed_at payment.processed_at
  json.status payment.payment_status_name&.downcase
  json.amount payment.amount_value
  json.initiated_by payment.initiating_user&.name
  if payment.completed? || payment.processing?
    json.utr payment.reference_resource&.bank_reference_number
  end
  json.bank_payment_request_id payment.payment_order.bank_payment_request.id
  json.payment_order_id payment.payment_order.bank_payment_request.id
  json.api_initiated payment.api_initiated
  json.custom_fields do
    invoice = payment.invoice
    if invoice.present?
      json.array! invoice&.custom_fields
    end
  end
  json.invoice_date payment.invoice&.date
  json.credited_date payment.reference_resource&.created_at&.strftime("%Y-%m-%d")
  json.invoice do
    invoice = payment.invoice
    json.tds invoice&.tds_amount&.value
    json.tax invoice&.tax_amount&.value
    json.net_amount payment.amount_value
  end
end