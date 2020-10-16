class SearchIndex::Index::Attribute

  attr_accessor :name, :searchable, :displayed, :primary_key, :faceted, :crop_length

  def initialize(name, faceted: false, searchable: true, displayed: true, primary_key: false, crop_length: nil)
    self.name = name
    self.faceted = faceted
    self.searchable = searchable
    self.displayed = displayed
    self.primary_key = primary_key
    self.crop_length = crop_length
  end

end