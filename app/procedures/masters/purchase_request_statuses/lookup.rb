class Masters::PurchaseRequestStatuses::Lookup < Lookup::API

  resolver 'purchase_request_statuses.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
end