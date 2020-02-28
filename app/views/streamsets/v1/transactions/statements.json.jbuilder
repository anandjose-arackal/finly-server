# These fields are a replica of Payment Ticket Exports
json.result do
  json.array!(@result.paginated_payments) do |payment|
    # standard fields
    json.id payment.id
    json.amount payment.amount.value
    json.created_at payment.created_at.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_ticket_id payment.payment_order&.bank_payment_request&.id
    json.payment_ticket_name payment.payment_order&.bank_payment_request&.name
    json.beneficiary_name payment.receiving_account&.account_owner&.name
    json.beneficiary_code (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.vendor_id : nil)
    json.beneficiary_pan (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.pan : nil)
    json.beneficiary_msme_number (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.msme_registration_number : nil)
    json.beneficiary_account_name payment.receiving_account&.name
    json.beneficiary_account_number payment.receiving_account&.account_number
    json.beneficiary_ifsc payment.receiving_account&.ifsc
    json.payment_mode payment.payment_mode&.upcase
    json.initiated_by payment.initiating_user&.name
    json.initiater_email payment.initiating_user&.email
    json.payment_order_status payment.payment_order&.bank_payment_request.status&.name&.humanize
    json.payment_order_schedule_date payment.payment_order&.scheduled_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_order_submitted_date payment.payment_order&.bank_payment_request.submitted_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.payment_order_processed_date payment.payment_order&.processed_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.bank_reference_number payment.reference_resource&.bank_reference_number
    json.finance_approved_date payment.payment_order&.bank_payment_request&.approved_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.note payment.note

    # extra fields

  end
end
json.count @result.payments.count