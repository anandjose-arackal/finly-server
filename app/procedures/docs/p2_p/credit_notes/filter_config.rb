class Docs::P2P::CreditNotes::FilterConfig < Filters::API

  index_builder 'credit_notes'

  attribute :sequence_id, label: "Credit Note Number", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :credit_note_date, label: "Credit Note Date", type: :datetime, simple: true
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].('policies')
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown,  choices: Choices[:auto_complete].("vendor")
  attribute :vendor_vendor_id, label: "Vendor ID", simple: false
  attribute :billing_location_id, label: "Billing Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  attribute :shipping_location_id, label: "Shipping Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  attribute :cost_center_id, label: "Cost Center", simple: true, type: :dropdown, choices: Choices[:auto_complete].("cost_centers")
  attribute :department_id, label: "Department", simple: true, type: :dropdown, choices: Choices[:auto_complete].("departments")
  attribute :gross_receivable_amount_value, label: "Gross Receivable Amount", type: :number
  attribute :net_receivable_amount_value, label: "Net Receivable Amount", type: :number

end