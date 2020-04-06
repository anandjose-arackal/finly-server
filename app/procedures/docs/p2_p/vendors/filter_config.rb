class Docs::P2P::Vendors::FilterConfig < Filters::API

  attribute :legal_name, type: :text, simple: true
  attribute :invoice_number, label: "Invoice Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :date, label: "Invoice Date", type: :datetime, simple: true
  attribute :due_date, label: "Due Date", type: :datetime, simple: true
  attribute :vendor_id, label: "Vendor", simple: true, type: :lookup,  auto_complete_route: "vendor"
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :location_id, label: "Billing Location", type: :lookup, auto_complete_route: "locations"
  attribute :delivery_location_id, label: "Shipping Location", type: :lookup, auto_complete_route: "locations"
  attribute :items_cost_center_id, label: "Cost Center", type: :lookup, auto_complete_route: "cost_centers"
  attribute :items_department_id, label: "Department", type: :lookup, auto_complete_route: "departments"

end