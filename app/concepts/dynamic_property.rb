module DynamicProperty

  def self.included(base)
    base.extend ClassMethods
  end

  def dynamic_property_map(scope=:singleton)
    case scope
    when :singleton
      DEFINABLE_PROPERTY_MAP[self.class.name] = {} if DEFINABLE_PROPERTY_MAP[self.class.name].nil?
      DEFINABLE_PROPERTY_MAP[self.class.name]
    when :instance
      RequestStore.store[self.class.name] = {} if RequestStore.store[self.class.name].nil?
      RequestStore.store[self.class.name]
    end
  end

  module ClassMethods

    def dynamic_property_map(scope = :singleton)
      case scope
      when :singleton
        DEFINABLE_PROPERTY_MAP[self.name] = {} if DEFINABLE_PROPERTY_MAP[self.name].nil?
        DEFINABLE_PROPERTY_MAP[self.name]
      when :instance
        RequestStore.store[self.name] = {} if RequestStore.store[self.name].nil?
        RequestStore.store[self.name]
      end
    end

    def define_property(scope, *attrs)
      property_type = property_type_for scope
      attrs.each do |method|
        send property_type, method do |value = NoObject|
          unless value == NoObject
            dynamic_property_map(scope)[method] = value
          end
          dynamic_property_map(scope)[method]
        end
      end
    end

    def define_property_array(scope, *attrs)
      property_type = property_type_for scope
      attrs.each do |method|
        send property_type, method do |value = NoObject|
          if dynamic_property_map(scope)[method].nil?
            dynamic_property_map(scope)[method] = []
          end
          unless value == NoObject
            dynamic_property_map(scope)[method] << value
          end
          dynamic_property_map(scope)[method]
        end
      end
    end

    private

    def property_type_for(scope)
      case scope
      when :singleton
        return :define_singleton_method
      when :instance
        return :define_method
      else
        raise "Invalid scope : #{scope}"
      end
    end

  end

end