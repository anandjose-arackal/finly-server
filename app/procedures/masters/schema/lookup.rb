class Masters::Schema::Lookup < Lookup::API
  resolver 'master_schemas.default'
  search_key :name

  attribute :name
  attribute :master_key
  attribute :active
end