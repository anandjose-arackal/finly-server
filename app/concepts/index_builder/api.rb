class IndexBuilder::API
  include Attribute::Builder
  include DynamicAttributes

  class_attr :resolver

  def self.config(user)
    config = {fixed: [], dynamic: []}
    attributes.each do |field_key, attribute|
      if attribute.fixed
        config[:fixed] << attribute.config(user)
      else
        config[:dynamic] << attribute.config(user)
      end
    end
    config
  end

  def self.build(user, record, fields)
    map = {}
    attributes.each do |field_key, attribute|
      next if fields.present? and not (fields.include?(field_key.to_s) or fields.include?(field_key.to_sym))

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