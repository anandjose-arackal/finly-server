class Docs::PaymentTickets::FilterConfig < Filters::API

  attribute :id, type: :text

  # attribute :po_number, label: "PO Number", type: :text, simple: true
  # attribute :created_at, type: :datetime, simple: false
  # attribute :submitted_at, type: :datetime, simple: false
  # attribute :approved_at, type: :datetime, simple: false
  # attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].("policies")
  # attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:auto_complete].('vendor')
  # attribute :vendor_vendor_id, label: "Vendor ID"
  # attribute :location_id, label: "Billing Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  # attribute :delivery_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  # attribute :items_cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:auto_complete].("cost_centers")
  # attribute :items_department_id, label: "Department", type: :dropdown, choices: Choices[:auto_complete].("departments")

end