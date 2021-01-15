class Docs::P2P::Invoices::InvoiceLineItems::FilterConfig < Filters::API

  index_builder Docs::P2P::Invoices::Index
  # custom_fields :invoice

  INVOICE_TYPES = [
      {id: InwardInvoiceType.id_for(:tax_invoice), name: "PO Invoice"},
      {id: InwardInvoiceType.id_for(:non_po_invoice), name: "Non-PO Invoice"},
      {id: InwardInvoiceType.id_for(:recurring_invoice), name: "Agreement Invoice"},
  ]

  attribute :parent_invoice_id, label: "Invoice ID", type: :text, simple: true
  attribute :parent_invoice_number, label: "Invoice Number", type: :text, simple: true
  attribute :parent_created_at, type: :datetime, simple: false
  attribute :parent_updated_at, type: :datetime, simple: false
  attribute :parent_submitted_at, type: :datetime, simple: false
  attribute :parent_approved_at, type: :datetime, simple: false
  attribute :parent_date, label: "Invoice Date", type: :datetime, simple: true
  attribute :parent_due_date, label: "Due Date", type: :datetime, simple: true
  attribute :parent_invoice_type_id, label: "Type", type: :dropdown, simple: true, choices: Choices[:list].(*INVOICE_TYPES)
  attribute :parent_policy_id, type: :dropdown, simple: false, choices: Choices[:lookup].('policies')
  attribute :parent_vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:lookup].("vendors")
  attribute :parent_vendor_vendor_id, label: "Vendor ID", simple: false
  attribute :parent_location_id, label: "Billing Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :parent_delivery_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:lookup].("cost_centers")
  attribute :department_id, label: "Department", type: :dropdown, choices: Choices[:lookup].("departments")
  attribute :parent_created_by_user_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")
  attribute :parent_controlling_level_level_number, label: "Controlling Level", type: :number, simple: true
  attribute :parent_controlling_user, label: "Controlling User", type: :dropdown, simple: true, choices: Choices[:lookup].("users")

end