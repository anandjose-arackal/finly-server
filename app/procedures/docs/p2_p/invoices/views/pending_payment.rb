class Docs::P2P::Invoices::Views::PendingPayment < IndexSegment::SystemViews::API

  system_subscription 'vp'
  screen 'invoices.index'
  label 'Pending Payment'
  permissions UserRole.ids_for(%w(
    bank_payment_request_initiator
    bank_payment_request_reviewer
    po_invoice_initiator
    po_invoice_reviewer
    po_invoice_auditor
    non_po_invoice_initiator
    non_po_invoice_reviewer
    non_po_invoice_auditor
    agreement_invoice_initiator
    agreement_invoice_reviewer
    agreement_invoice_auditor
    creditor
    admin
  ))
  filter 'invoice_status_id', :eq, InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid)
  columns %i(
      :created_by
      :submitted_at,
      :approved_at,
      :status,
      :net_amount,
      :gross_amount,
      :tds_amount,
      :location,
      :department,
      :cost_center,
      :balance_due
   )

end