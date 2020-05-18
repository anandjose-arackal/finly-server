class Docs::P2P::CreditNotes::FilterConfig < Filters::API

  attribute :sequence_id, label: "Credit Note Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :credit_note_date, label: "Credit Note Date", type: :datetime, simple: true
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:lookup].('policies')
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown,  choices: Choices[:lookup].("vendors")
  attribute :vendor_vendor_id, label: "Vendor ID", simple: false
  attribute :billing_location_id, label: "Billing Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :shipping_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :cost_center_id, label: "Cost Center", simple: true, type: :dropdown, choices: Choices[:lookup].("cost_centers")
  attribute :department_id, label: "Department", simple: true, type: :dropdown, choices: Choices[:lookup].("departments")
  attribute :gross_receivable_amount_value, label: "Gross Receivable Amount", type: :number
  attribute :net_receivable_amount_value, label: "Net Receivable Amount", type: :number

end