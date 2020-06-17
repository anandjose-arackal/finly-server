class Dashboard::P2P::Invoices < Dashboard::IndexCard

  index_route 'invoices'
  path 'invoices'
  created_by :created_by_user_id
  policy :policy_id
  location :delivery_location_id
  department :items_department_id
  cost_center :items_cost_center_id
  scope_status InwardInvoiceStatus.id_for(:processing),
               InwardInvoiceStatus::GROUP_PENDING_PAYMENT,
               InwardInvoiceStatus.id_for(:paid)

end