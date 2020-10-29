class Masters::Policies::Lookup < Lookup::API

  resolver 'policies.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
  attribute :created_at, value: "{{record.created_at}}"
  attribute :updated_at

end