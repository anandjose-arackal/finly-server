class Masters::Items::Lookup < Lookup::API

  resolver 'items.default'
  search_key :item_number_or_description_cont
  data_card_route 'masters.items'

  attribute :id, visible: false
  attribute :item_number
  attribute :name, value: :description
  attribute :product_type_id
  attribute :category_id
  attribute :unit_of_measurement
  attribute :rate
end