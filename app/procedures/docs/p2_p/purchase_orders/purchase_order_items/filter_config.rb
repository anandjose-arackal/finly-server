class Docs::P2P::PurchaseOrders::PurchaseOrderItems::FilterConfig < Filters::API

  index_builder Docs::P2P::PurchaseOrders::Index

  attribute :purchase_order_po_number, label: "PO Number", type: :text, simple: true
  attribute :purchase_order_created_at, type: :datetime, simple: false
  attribute :purchase_order_submitted_at, type: :datetime, simple: false
  attribute :purchase_order_approved_at, type: :datetime, simple: false
  attribute :purchase_order_policy_id, type: :dropdown, simple: true, choices: Choices[:lookup].("policies")
  attribute :purchase_order_vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:lookup].('vendors')
  attribute :purchase_order_vendor_vendor_id, label: "Vendor ID"
  attribute :purchase_order_location_id, label: "Billing Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :purchase_order_delivery_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:lookup].("cost_centers")
  attribute :department_id, label: "Department", type: :dropdown, choices: Choices[:lookup].("departments")
  attribute :purchase_order_user_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")
  attribute :purchase_request_item_purchase_request_order_number, label: "Purchase Request ID", type: :text
  attribute :purchase_order_controlling_level_level_number, label: "Controlling Level", type: :number, simple: true
  attribute :purchase_order_controlling_user, label: "Controlling User", type: :dropdown, simple: true, choices: Choices[:lookup].("users")
  # custom_fields :purchase_order

end