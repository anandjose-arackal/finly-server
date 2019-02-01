module DynamicProperty

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def dynamic_property_map
      DEFINABLE_PROPERTY_MAP[self.name] = {} if DEFINABLE_PROPERTY_MAP[self.name].nil?
      DEFINABLE_PROPERTY_MAP[self.name]
    end

    def define_property(*attrs)
      attrs.each do |method|
        define_singleton_method method do |value = NoObject|
          unless value == NoObject
            dynamic_property_map[method] = value
          end
          dynamic_property_map[method]
        end
      end
    end

    def define_property_array(*attrs)
      attrs.each do |method|
        define_singleton_method method do |value = NoObject|
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
    
  end

end