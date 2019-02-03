module DynamicProperty

  def self.included(base)
    base.extend ClassMethods
  end

  def dynamic_property_map
    DEFINABLE_PROPERTY_MAP[self.class.name] = {} if DEFINABLE_PROPERTY_MAP[self.class.name].nil?
    DEFINABLE_PROPERTY_MAP[self.class.name]
  end

  module ClassMethods

    def dynamic_property_map
      DEFINABLE_PROPERTY_MAP[self.name] = {} if DEFINABLE_PROPERTY_MAP[self.name].nil?
      DEFINABLE_PROPERTY_MAP[self.name]
    end

    def define_property(scope, *attrs)
      property_type = property_type_for scope
      attrs.each do |method|
        send property_type, method do |value = NoObject|
          unless value == NoObject
            self.dynamic_property_map[method] = value
          end
          self.dynamic_property_map[method]
        end
      end
    end

    def define_property_array(scope, *attrs)
      property_type = property_type_for scope
      attrs.each do |method|
        send property_type, method do |value = NoObject|
          if dynamic_property_map[method].nil?
            dynamic_property_map[method] = []
          end
          unless value == NoObject
            dynamic_property_map[method] << value
          end
          dynamic_property_map[method]
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