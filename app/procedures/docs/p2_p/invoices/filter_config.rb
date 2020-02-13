class Docs::P2P::Invoices::FilterConfig < Filters::API

  attribute :invoice_id, label: "Invoice ID", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: true
  attribute :updated_at, type: :datetime, simple: true
  attribute :created_by_name, label: "Created By", type: :lookup, scope: 'users'
  attribute :vendor_business_name, label: "Vendor Name", simple: true
  attribute :vendor_vendor_id, label: "Vendor ID", simple: true

end