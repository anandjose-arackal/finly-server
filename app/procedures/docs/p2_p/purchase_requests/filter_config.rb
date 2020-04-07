class Docs::P2P::PurchaseRequests::FilterConfig < Filters::API

  attribute :order_number, label: "Purchase Request ID", type: :text, simple: true
  attribute :policy, type: :lookup, simple: true, auto_complete_route: 'policies'
  attribute :created_at, type: :datetime, simple: true
  attribute :updated_at, type: :datetime, simple: true
  attribute :submitted_at, type: :datetime, simple: true
  attribute :approved_at, type: :datetime
  attribute :total_amount, type: :amount
  attribute :items_item_description, label: "Description", type: :text, simple: true
  attribute :items_cost_center_id, label: "Cost Center", type: :lookup, auto_complete_route: "cost_centers"
  attribute :items_department_id, label: "Department", type: :lookup, auto_complete_route: "departments"

end