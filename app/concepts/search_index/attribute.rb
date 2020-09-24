class SearchIndex::Attribute

  attr_accessor :name, :searchable, :displayed, :primary_key, :faceted

  def initialize(name, faceted: false, searchable: true, displayed: true, primary_key: false)
    self.name = name
    self.faceted = faceted
    self.searchable = searchable
    self.displayed = displayed
    self.primary_key = primary_key
  end

end