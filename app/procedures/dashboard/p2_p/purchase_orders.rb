class Dashboard::P2P::PurchaseOrders < Dashboard::IndexCard

  index_route 'purchase_orders'
  path 'purchase_orders'
  created_by :user_id
  scope_status PurchaseOrderStatus.id_for(:processing),
               PurchaseOrderStatus::GROUP_APPROVED,
               PurchaseOrderStatus.id_for(:sent_to_vendor),
               PurchaseOrderStatus.id_for(:vendor_confirmed)

end