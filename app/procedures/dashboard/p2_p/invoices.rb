class Dashboard::P2P::Invoices < Dashboard::Card

  resolver 'invoices.default'
  path 'invoices'
  created_by :created_by_user_id
  status :invoice_status_id
  row "admin" do
    tile "All"
    tile "Processing", filter_status: InwardInvoiceStatus.id_for(:processing)
    tile "Approved", filter_status: InwardInvoiceStatus::GROUP_PENDING_PAYMENT
    tile "Paid", filter_status: InwardInvoiceStatus.id_for(:paid)
  end
  row "personal", filter_created_by: true do
    tile "All"
    tile "Processing", filter_status: InwardInvoiceStatus.id_for(:processing)
    tile "Approved", filter_status: InwardInvoiceStatus::GROUP_PENDING_PAYMENT
    tile "Paid", filter_status: InwardInvoiceStatus.id_for(:paid)
  end

end