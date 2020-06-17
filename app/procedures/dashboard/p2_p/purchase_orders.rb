class Dashboard::P2P::PurchaseOrders < Dashboard::IndexCard

  index_route 'purchase_orders'
  path 'purchase_orders'
  created_by :user_id
  policy :policy_id
  location :delivery_location_id
  department :items_department_id
  cost_center :items_cost_center_id
  scope_status PurchaseOrderStatus.id_for(:processing),
               PurchaseOrderStatus::GROUP_APPROVED,
               PurchaseOrderStatus.id_for(:sent_to_vendor),
               PurchaseOrderStatus.id_for(:vendor_confirmed)

end