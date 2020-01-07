json.result do
  json.array!(@result.paginated_payments) do |payment|
    json.id payment.id
    json.amount payment.amount.value
    json.payment_ticket_id payment.payment_order&.bank_payment_request&.id
    json.payment_ticket_name payment.payment_order&.bank_payment_request&.name
    json.beneficiary_name payment.receiving_account&.account_owner&.name
    json.beneficiary_code (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user&.vendor_id : nil)
    json.beneficiary_account_name payment.receiving_account&.name
    json.beneficiary_account_number payment.receiving_account&.account_number
    json.payment_mode payment.payment_mode&.upcase
    json.initiated_by payment.initiating_user&.name
    json.initiater_email payment.initiating_user&.email
    json.payment_order_status payment.payment_order&.bank_payment_request.status&.name&.humanize
    json.payment_order_scshedule_date payment.payment_order&.scheduled_at&.strftime("%d-%b-%Y")
    json.payment_order_submitted_date payment.payment_order&.bank_payment_request.submitted_at&.strftime("%d-%b-%Y")
    json.payment_order_processed_date payment.payment_order&.processed_at&.strftime("%d-%b-%Y")
    json.bank_reference_number payment.reference_resource&.bank_reference_number

    po_number = ''
    if (payment.parent_type == 'PurchaseOrder') || (payment.parent_type == 'Invoice')
      po_number = payment.parent.po_number rescue ''
    end
    json.po_number po_number

    json.invoice_type payment.invoice&.invoice_type&.name&.titleize
    json.invoice_number payment.invoice&.invoice_number
    json.invoice_due_date payment.invoice&.due_date&.strftime("%d-%b-%Y")
    json.invoice_date payment.invoice&.date&.strftime("%d-%b-%Y")
    json.invoice_id payment.invoice&.invoice_id

  end
end
json.count @result.payments.count