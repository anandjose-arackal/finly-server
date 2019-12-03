module DynamicAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Same as class_attribute of ruby.
    # Over class_attribute this allows setting values by calling attribute(value) instead of attribute = value
    # alternate getter: self.attribute_#{name}
    # alternate setter: self.attribute_#{name}=
    def class_attr(name, default: nil)
      attribute = "attribute_#{name}"
      class_attribute attribute, default: default
      define_singleton_method name do |value = NoObject|
        send("#{attribute}=", value) unless value == NoObject
        send(attribute)
      end
      send(attribute)
    end

    # same as attr_accessor.
    # Over attr_accessor this allows setting values by calling attribute(value) instead of attribute = value
    def instance_attr(name, default: NoObject)
      define_method name do |value = NoObject|
        instance_variable_set("@#{name}", value) unless value == NoObject
        instance_variable_set("@#{name}", default) unless instance_variable_defined?("@#{name}") or default == NoObject
        instance_variable_get("@#{name}")
      end
    end
  end

end