class Masters::Vendors::Locations::Lookup < Lookup::API

  resolver 'vendors.locations.default'
  search_key :location_or_gstin_cont

  attribute :id, visible: false
  attribute :name, value: :location
  attribute :address
  attribute :gstin
  attribute :poc_name
  attribute :poc_mobile_number
  attribute :poc_email

end