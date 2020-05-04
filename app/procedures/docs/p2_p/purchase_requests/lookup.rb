class Docs::P2P::PurchaseRequests::Lookup < Lookup::API

  resolver 'purchase_requests.default'
  search_key :order_number_cont

  attribute :id, visible: false
  attribute :request_id, label: 'Request ID'
  attribute :name, value: :description

end