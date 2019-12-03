module DynamicAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def class_attr(name, default: NoObject)
      class_attrs << name
      unless class_attrs.include?(:name)
        define_singleton_method name do |value = NoObject|
          instance_variable_set("@#{name}", value) unless value == NoObject
          instance_variable_set("@#{name}", default) unless instance_variable_defined?("@#{name}") or default == NoObject
          instance_variable_get("@#{name}")
        end
      end
      instance_variable_get("@#{name}")
    end

    def class_attrs
      @class_attrs ||= []
    end

    def inherited(klass)
      class_attrs&.each { |key| klass.send(key, send(key)) }
      super(klass)
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