class Docs::P2P::Agreements::FilterConfig < Filters::API

  index_builder 'agreements'

  attribute :order_number, label: "Agreement ID", type: :text, simple: true
  attribute :title, simple: true
  attribute :agreement_date, type: :datetime, simple: true
  attribute :execution_date, type: :datetime, simple: true
  attribute :expiration_date, type: :datetime
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :submitted_at, type: :datetime
  attribute :approved_at, type: :datetime
  attribute :policy_id, type: :dropdown, simple: false, choices: Choices[:lookup].('policies')

end