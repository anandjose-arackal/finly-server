class Masters::Categories::Lookup < Lookup::API

  resolver 'categories.default'
  search_key :name_or_category_code_cont
  data_card_route 'masters.categories'

  attribute :id, visible: false
  attribute :category_code
  attribute :name

end