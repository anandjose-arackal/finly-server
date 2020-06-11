class Dashboard::P2P::Invoices < Dashboard::IndexCard

  index_route 'invoices'
  path 'invoices'
  created_by :created_by_user_id
  scope_status InwardInvoiceStatus.id_for(:processing),
               InwardInvoiceStatus::GROUP_PENDING_PAYMENT,
               InwardInvoiceStatus.id_for(:paid)

end