class Masters::States::Lookup < Lookup::API

  resolver 'states.default'
  search_key :name_or_code_cont
  data_card_route 'masters.states'

  attribute :id, visible: false
  attribute :name
  attribute :code
  attribute :state_code

end