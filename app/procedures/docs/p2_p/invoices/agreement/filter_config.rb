class Docs::P2P::Invoices::Agreement::FilterConfig < Filters::API

  attribute :invoice_id, label: "Invoice ID", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: true
  attribute :updated_at, type: :datetime, simple: true
  # attribute :created_by_name, label: "Created By", type: :lookup, auto_complete_route: 'users'
  attribute :vendor_business_name, label: "Vendor Name", simple: true
  attribute :vendor_vendor_id, label: "Vendor ID", simple: true
  attribute :location_id, label: "Billing Location", type: :lookup, auto_complete_route: "locations"
  attribute :delivery_location_id, label: "Shipping Location", type: :lookup, auto_complete_route: "locations"
  attribute :items_cost_center_id, label: "Cost Center", type: :lookup, auto_complete_route: "cost_centers"
  attribute :items_department_id, label: "Department", type: :lookup, auto_complete_route: "departments"

end