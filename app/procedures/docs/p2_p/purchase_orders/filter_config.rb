class Docs::P2P::PurchaseOrders::FilterConfig < Filters::API

  attribute :po_number, label: "PO Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :policy, type: :lookup, simple: true, auto_complete_route: 'policies'
  attribute :vendor_id, label: "Vendor", simple: true, type: :lookup,  auto_complete_route: "vendor"
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :location_id, label: "Billing Location", type: :lookup, auto_complete_route: "locations"
  attribute :delivery_location_id, label: "Shipping Location", type: :lookup, auto_complete_route: "locations"
  attribute :items_cost_center_id, label: "Cost Center", type: :lookup, auto_complete_route: "cost_centers"
  attribute :items_department_id, label: "Department", type: :lookup, auto_complete_route: "departments"

end