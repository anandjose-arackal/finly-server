class Masters::PurchaseOrderStatuses::Lookup < Lookup::API

  resolver 'purchase_order_statuses.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
end