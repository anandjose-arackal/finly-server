class Masters::Countries::Lookup < Lookup::API

  resolver 'countries.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name

  def self.max_per_page
    200
  end
  
end