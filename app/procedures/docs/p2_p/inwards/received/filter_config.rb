class Docs::P2P::Inwards::Received::FilterConfig < Filters::API

  index_builder Docs::P2P::Inwards::Received::Index

  attribute :purchase_order_po_number, label: "PO Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :delivered_on, type: :datetime, simple: false
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:auto_complete].('vendor')
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :delivery_date, label: "Delivered On", type: :datetime
  attribute :grn_number, label: "Reference Number", simple: true
  attribute :user_id, label: "Created By", type: :dropdown, choices: Choices[:auto_complete].("users")
  attribute :items_purchase_order_item_purchase_order_policy_id, label: "PO Policy", choices: Choices[:auto_complete].("policies")
  attribute :items_purchase_order_item_department_id, label: "PO Department", choices: Choices[:auto_complete].("departments")
  attribute :items_purchase_order_item_cost_center_id, label: "PO Cost Center", choices: Choices[:auto_complete].("cost_centers")
  attribute :items_purchase_order_item_purchase_order_delivery_location_id, label: "PO Delivery Location", choices: Choices[:auto_complete].("locations")

end