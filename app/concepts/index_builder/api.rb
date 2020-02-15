class IndexBuilder::API
  include Attribute::Builder
  include DynamicAttributes

  class_attr :resolver

  def self.config(user)
    config = []
    attributes.each do |field_key, attribute|
      config << attribute.config(user)
    end
    config
  end

  def self.build(user, record)
    map = {}
    attributes.each do |field_key, attribute|
      map[attribute.field_key] = attribute.build(self, user, record)
    end
    map
  end

  def self.include_associations!(collection)
    includes = []
    attributes.each do |field_key, attribute|
      includes += attribute.includes
    end
    collection.includes(includes.uniq)
  end

end