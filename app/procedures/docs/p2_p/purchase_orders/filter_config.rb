class Docs::P2P::PurchaseOrders::FilterConfig < Filters::API

  index_builder 'purchase_orders'

  attribute :po_number, label: "PO Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:lookup].("policies")
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:lookup].('vendors')
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :location_id, label: "Billing Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :delivery_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :items_cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:lookup].("cost_centers")
  attribute :items_department_id, label: "Department", type: :dropdown, choices: Choices[:lookup].("departments")
  custom_fields :purchase_order

end