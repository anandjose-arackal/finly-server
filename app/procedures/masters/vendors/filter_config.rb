class Masters::Vendors::FilterConfig < Filters::API

  attribute :vendor_id, label: "Vendor ID", type: :text, simple: true
  attribute :legal_name, type: :text, simple: true
  attribute :trade_name, type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :vendor_type, type: :dropdown, choices: Choices[:resolver].("vendor_types.default")
  attribute :payment_terms, type: :dropdown, choices: Choices[:resolver].("payment_terms.default")
  attribute :policy_id, type: :dropdown, choices: Choices[:auto_complete].("policies")

end