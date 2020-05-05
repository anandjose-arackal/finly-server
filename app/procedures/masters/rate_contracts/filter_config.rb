class Masters::RateContracts::FilterConfig < Filters::API

  attribute :name, type: :text, simple: true
  attribute :rate_contract_id, label: 'Rate Contract ID', type: :text, simple: true
  attribute :vendor_id, label: "Vendor", simple: true, type: :dropdown,  choices: Choices[:lookup].("vendors")
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :renewable, type: :checkbox, choices: Choices[:switch].()

end