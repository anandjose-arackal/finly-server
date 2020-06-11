class Docs::P2P::Invoices::Agreement::UpcomingInvoices::FilterConfig < Filters::API

  index_builder Docs::P2P::Invoices::Agreement::UpcomingInvoices::Index

  # attribute :invoice_id, label: "Invoice ID", type: :text, simple: true
  # attribute :invoice_number, label: "Invoice Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  # attribute :date, label: "Invoice Date", type: :datetime, simple: true
  attribute :start_date, type: :datetime
  attribute :end_date, type: :datetime
  attribute :payment_agreement_order_number, label: "Agreement Number", type: :text, simple: true
  attribute :due_date, label: "Due Date", type: :datetime, simple: true
  # attribute :policy_id, type: :dropdown, simple: false, choices: Choices[:auto_complete].('policies')
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown,  choices: Choices[:auto_complete].("vendor")
  attribute :vendor_vendor_id, label: "Vendor ID", simple: false
  attribute :location_id, label: "Billing Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  attribute :delivery_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  attribute :items_cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:auto_complete].("cost_centers")
  attribute :items_department_id, label: "Department", type: :dropdown, choices: Choices[:auto_complete].("departments")
  attribute :created_by_user_id, label: "Created By", type: :dropdown, choices: Choices[:auto_complete].("users")

end