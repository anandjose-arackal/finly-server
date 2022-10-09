class Masters::Vendors::Lookup < Lookup::API

  resolver 'vendors.default'
  search_key :business_name_or_trade_name_or_vendor_id_cont
  data_card_route 'forms.vendors'

  attribute :id, visible: false
  attribute :vendor_id
  attribute :name, value: :business_name
  attribute :trade_name
  attribute :vendor_country

end