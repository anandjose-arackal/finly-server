class Docs::P2P::Inwards::Received::FilterConfig < Filters::API

  attribute :purchase_order_po_number, label: "PO Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :delivered_at, type: :datetime, simple: false
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:auto_complete].('vendor')
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :delivery_date, label: "Delivery Date", type: :datetime
  attribute :grn_number, label: "Reference Number", simple: true

end