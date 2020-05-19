class Docs::P2P::Inwards::Received::FilterConfig < Filters::API

  index_builder 'receive_history'

  attribute :purchase_order_po_number, label: "PO Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :delivered_on, type: :datetime, simple: false
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown, choices: Choices[:lookup].('vendors')
  attribute :vendor_vendor_id, label: "Vendor ID"
  attribute :delivery_date, label: "Delivered On", type: :datetime
  attribute :grn_number, label: "Reference Number", simple: true

end