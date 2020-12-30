class Docs::P2P::PurchaseOrders::FilterConfig < Filters::API

  index_builder Docs::P2P::PurchaseOrders::Index

  STATUS_TYPES = PurchaseOrderStatus.all.map{ |pos| {id: pos.id, name: pos.name.titleize } }

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
  attribute :user_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")
  attribute :items_purchase_request_item_purchase_request_order_number, label: "Purchase Request ID", type: :text
  attribute :controlling_level_level_number, label: "Controlling Level", type: :number, simple: true
  attribute :controlling_user, label: "Controlling User", type: :dropdown, simple: true, choices: Choices[:lookup].("users")
  attribute :status, type: :dropdown, simple: false, choices: Choices[:list].(*STATUS_TYPES)
  custom_fields :purchase_order

end