class Masters::Items::Lookup < Lookup::API

  resolver 'items.default'
  search_key :item_number_or_description_cont

  attribute :id, visible: false
  attribute :item_number
  attribute :name, value: :description

end