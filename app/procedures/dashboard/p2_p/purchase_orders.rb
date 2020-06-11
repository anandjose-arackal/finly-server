class Dashboard::P2P::PurchaseOrders < Dashboard::Card

  resolver 'purchase_orders.default'
  path 'purchase_orders'
  created_by :user_id
  status :purchase_order_status_id
  row "admin" do
    tile "All"
    tile "Processing", filter_status: PurchaseOrderStatus.id_for(:processing)
    tile "Approved", filter_status: PurchaseOrderStatus::GROUP_APPROVED
    tile "Sent to Vendor", filter_status: PurchaseOrderStatus.id_for(:sent_to_vendor)
    tile "Vendor Confirmed", filter_status: PurchaseOrderStatus.id_for(:vendor_confirmed)
  end
  row "personal", filter_created_by: true do
    tile "All"
    tile "Processing", filter_status: PurchaseOrderStatus.id_for(:processing)
    tile "Approved", filter_status: PurchaseOrderStatus::GROUP_APPROVED
    tile "Sent to Vendor", filter_status: PurchaseOrderStatus.id_for(:sent_to_vendor)
    tile "Vendor Confirmed", filter_status: PurchaseOrderStatus.id_for(:vendor_confirmed)
  end

end