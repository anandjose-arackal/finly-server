module Lookup::DSL
  extend ActiveSupport::Concern

  included do
    include DynamicAttributes

    class_attr :model
    class_attr :resolver
    class_attr :max_per_page, default: 10
    class_attr :search_key
    class_attr :attributes, default: {}
  end

  class_methods do
    def attribute(id, label: nil, value: nil, visible: true, includes: [])
      self.attributes[id] = Lookup::Attribute.new(id: id, label: label, value: value, includes: includes, visible: visible)
    end

    def associations_to_include
      associations = []
      self.attributes.each_pair do |id, attribute|
        associations += attribute.includes if attribute.includes.present?
      end
      associations
    end

    def attributes_config
      config = []
      self.attributes.each_pair do |id, attribute|
        config << attribute.config
      end
      config
    end
  end

end