class Masters::Items::FilterConfig < Filters::API

  attribute :vendor_id, label: "Vendor ID", type: :text, simple: true
  attribute :legal_name, type: :text, simple: true
  attribute :trade_name, type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  # attribute :vendor_type, type: :dropdown, resolver_route: 'vendor_types.default'
  # attribute :payment_terms, type: :dropdown, resolver_route: 'payment_terms.default'
  # attribute :policy, type: :lookup, auto_complete_route: 'policies'

  # attribute :date, label: "Invoice Date", type: :datetime, simple: true
  # attribute :due_date, label: "Due Date", type: :datetime, simple: true
  # attribute :vendor_id, label: "Vendor", simple: true, type: :lookup,  auto_complete_route: "vendor"
  # attribute :vendor_vendor_id, label: "Vendor ID"
  # attribute :location_id, label: "Billing Location", type: :lookup, auto_complete_route: "locations"
  # attribute :delivery_location_id, label: "Shipping Location", type: :lookup, auto_complete_route: "locations"
  # attribute :items_cost_center_id, label: "Cost Center", type: :lookup, auto_complete_route: "cost_centers"
  # attribute :items_department_id, label: "Department", type: :lookup, auto_complete_route: "departments"

end