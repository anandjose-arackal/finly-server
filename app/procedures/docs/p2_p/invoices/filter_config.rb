class Docs::P2P::Invoices::FilterConfig < Filters::API

  attribute :invoice_id, label: "Invoice ID", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: true
  attribute :updated_at, type: :datetime, simple: true
  # attribute :created_by_name, label: "Created By", type: :lookup, scope: 'users'
  attribute :vendor_business_name, label: "Vendor Name", simple: true
  attribute :vendor_vendor_id, label: "Vendor ID", simple: true
  attribute :location_id, label: "Billing Location", simple: true, scope: "locations"
  attribute :delivery_location_id, label: "Shipping Location", simple: true, scope: "locations"
  attribute :items_cost_center_id, label: "Cost Center", simple: true, scope: "cost_centers"
  attribute :items_department_id, label: "Department", simple: true, scope: "departments"

end