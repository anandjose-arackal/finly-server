module DynamicAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Same as class_attribute of ruby.
    # Over class_attribute this allows setting values by calling attribute(value) instead of attribute = value
    def xclass_attr(name, default: nil)
      attribute = "attribute_#{name}"
      class_attribute attribute #, default: default
      define_singleton_method name do |value = NoObject|
        send("#{attribute}=", value) if value != NoObject
        unless default.nil? or send(attribute).present?
          if default.is_a?(Array) or default.is_a?(Hash)
            send("#{attribute}=", default.dup)
          else
            send("#{attribute}=", default)
          end
        end
        send(attribute)
      end
      send(attribute)
    end

    def class_attr(name, default: nil)
      # attribute = "attribute_#{name}"
      # class_attribute attribute, default: default
      if default.respond_to?(:deep_dup) and not default.is_a?(Class)
        def_val = default.deep_dup
      elsif default.present?
        def_val = default
      end
      define_singleton_method name do |value = NoObject|
        if value == NoObject # Value has not been provided
          # Check if value is already present
          if instance_variable_get("@#{name}").nil?
            # Check in superclass
            if superclass.respond_to?(name)
              superclass_value = superclass.send(name)
              if superclass_value.nil?
                instance_variable_set("@#{name}", def_val)
              else
                if superclass_value.is_a?(Hash) || superclass_value.is_a?(Array)
                  instance_variable_set("@#{name}", superclass_value.dup)
                else
                  instance_variable_set("@#{name}", superclass_value)
                end
              end
              # p "super class #{superclass.name} responds to #{name}"
            else
              # superclass doesn't have the attribute & its not set for current class & value is not provided
              instance_variable_set("@#{name}", def_val)
            end
          else
            # Do nothing
          end
        else
          # Value is provided
          if instance_variable_get("@#{name}").nil?
            # value is not set in the current class
            instance_variable_set("@#{name}", value)
          end
        end

        instance_variable_get("@#{name}")
      end
    end

    # same as attr_accessor.
    # Over attr_accessor this allows setting values by calling attribute(value) instead of attribute = value
    def instance_attr(name, default: NoObject)
      define_method name do |value = NoObject|
        instance_variable_set("@#{name}", value) unless value == NoObject
        def_val = default.deep_dup if default.respond_to?(:deep_dup)
        instance_variable_set("@#{name}", def_val) unless instance_variable_defined?("@#{name}") or default == NoObject
        instance_variable_get("@#{name}")
      end
      alias_method :"#{name}=", name
    end
  end

end