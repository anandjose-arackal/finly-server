class Docs::P2P::PurchaseRequests::FilterConfig < Filters::API

  attribute :order_number, label: 'Purchase Request ID', type: :text, simple: true
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].('policies')
  attribute :created_at, type: :datetime, simple: true
  attribute :updated_at, type: :datetime, simple: true
  attribute :submitted_at, type: :datetime, simple: true
  attribute :approved_at, type: :datetime
  attribute :total_amount_value, type: :number
  attribute :items_item_description, label: 'Description', type: :text, simple: true
  attribute :items_cost_center_id, label: 'Cost Center', type: :dropdown, choices: Choices[:auto_complete].('cost_centers')
  attribute :items_department_id, label: 'Department', type: :dropdown, choices: Choices[:auto_complete].('departments')

end