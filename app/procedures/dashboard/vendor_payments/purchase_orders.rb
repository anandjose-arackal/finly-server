class Dashboard::VendorPayments::PurchaseOrders < Dashboard::Card

  resolver 'purchase_orders.default'
  path 'purchase_orders'
  created_by :user_id
  status :purchase_order_status_id
  row "admin" do
    tile "All"
    tile "Processing", filter_status: InwardInvoiceStatus.id_for(:processing)
    tile "Approved", filter_status: InwardInvoiceStatus.id_for(:approved)
    tile "Paid", filter_status: InwardInvoiceStatus.id_for(:paid)
  end
  row "personal", filter_created_by: true do
    tile "All"
    tile "Processing", filter_status: InwardInvoiceStatus.id_for(:processing)
    tile "Approved", filter_status: InwardInvoiceStatus.id_for(:approved)
    tile "Paid", filter_status: InwardInvoiceStatus.id_for(:paid)
  end

end