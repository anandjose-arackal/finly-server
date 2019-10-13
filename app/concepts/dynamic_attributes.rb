module DynamicAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def class_attr(name, default: NoObject)
      define_singleton_method name do |value = NoObject|
        instance_variable_set("@#{name}", value) unless value == NoObject
        instance_variable_set("@#{name}", default) unless instance_variable_defined?("@#{name}") or default == NoObject
        instance_variable_get("@#{name}")
      end
    end

    def instance_attr(name, default: NoObject)
      define_method name do |value = NoObject|
        instance_variable_set("@#{name}", value) unless value == NoObject
        instance_variable_set("@#{name}", default) unless instance_variable_defined?("@#{name}") or default == NoObject
        instance_variable_get("@#{name}")
      end
    end
  end

end