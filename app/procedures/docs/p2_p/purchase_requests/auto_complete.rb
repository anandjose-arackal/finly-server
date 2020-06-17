class Docs::P2P::PurchaseRequests::AutoComplete < AutoComplete::API

  resolver 'purchase_requests.default'
  json do |context, record|
    {
        id: record.id,
        name: record.description
    }
  end
  search_key :order_number_cont

end