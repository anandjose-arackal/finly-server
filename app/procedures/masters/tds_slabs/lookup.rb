class Masters::TdsSlabs::Lookup < Lookup::API

  resolver 'tds_slabs.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name, value: '{{record.tds | append: "% - " | append: record.name}}'
  attribute :tds

end