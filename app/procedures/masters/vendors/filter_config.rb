class Masters::Vendors::FilterConfig < Filters::API

  index_builder Masters::Vendors::Index

  attribute :vendor_id, label: "Vendor ID", type: :text, simple: true
  attribute :business_name, type: :text, simple: true
  attribute :trade_name, type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :submitted_at, type: :datetime, simple: false
  attribute :approved_at, type: :datetime, simple: false
  attribute :vendor_type_id, type: :dropdown, choices: Choices[:resolver].("vendor_types.default")
  attribute :payment_term_id, type: :dropdown, choices: Choices[:resolver].("payment_terms.default")
  attribute :payment_agreement_policy_id, type: :dropdown, choices: Choices[:lookup].("policies")

end