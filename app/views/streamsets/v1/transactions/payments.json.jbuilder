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

    po_number = ''
    if (payment.parent_type == 'PurchaseOrder') || (payment.parent_type == 'Invoice')
      po_number = payment.parent.po_number rescue ''
    end
    json.po_number po_number

    # extra fields
    json.invoice_type payment.invoice&.invoice_type&.name&.titleize
    json.invoice_number payment.invoice&.invoice_number
    json.invoice_due_date payment.invoice&.due_date&.strftime("%Y-%m-%d %H:%M:%S")
    json.invoice_date payment.invoice&.date&.strftime("%Y-%m-%d %H:%M:%S")
    json.invoice_id payment.invoice&.invoice_id
    json.invoice_buyer_location_state payment.invoice.location&.state&.name rescue ""
    json.invoice_buyer_location_code payment.invoice.location&.location_code rescue ""

    json.invoice_delivery_location_state payment.invoice.delivery_location&.state&.name rescue ""
    json.invoice_delivery_location_code payment.invoice.delivery_location&.location_code rescue ""

    json.invoice_gstin_location_state payment&.invoice&.gstin_location&.state&.name rescue ""
    json.invoice_gstin_location_city payment&.invoice&.gstin_location&.location rescue ""
    json.invoice_gstin_location_code payment&.invoice&.gstin_location&.state&.state_code rescue ""
    json.invoice_department_code payment.invoice&.items&.first.department&.department_code rescue ""

    json.invoice_gl_code payment.invoice&.category&.gl_code rescue ""

  end
end
json.count @result.payments.count