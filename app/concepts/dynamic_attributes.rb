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
      define_singleton_method name do |value = NoObject|
        # send("#{attribute}=", value) unless value == NoObject
        # debugger
        # if value == NoObject && instance_variable_get("@#{name}").nil?
        #   # p "#{name} not set in the class #{self.name}"
        #   if superclass.respond_to?(name)
        #     superclass_value = superclass.send(name)
        #     if superclass_value.nil?
        #       if value != NoObject
        #         instance_variable_set("@#{name}", value)
        #       else
        #         instance_variable_set("@#{name}", default)
        #       end
        #     else
        #       if superclass_value.is_a?(Hash) || superclass_value.is_a?(Array)
        #         instance_variable_set("@#{name}", superclass_value.dup)
        #       else
        #         instance_variable_set("@#{name}", superclass_value)
        #       end
        #     end
        #     # p "super class #{superclass.name} responds to #{name}"
        #   else
        #     # p "super class #{superclass.name} didn't responds to #{name} setting Payload to #{default}"
        #     # debugger
        #     instance_variable_set("@#{name}", default)# if @payload.blank?
        #   end
        # else
        #
        #   if value.nil? || value == NoObject
        #     instance_variable_set("@#{name}", default)
        #   else
        #     instance_variable_set("@#{name}", value)
        #   end
        # end

        if value == NoObject # Value has not been provided
          # Check if value is already present
          if instance_variable_get("@#{name}").nil?
            # Check in superclass
            if superclass.respond_to?(name)
              superclass_value = superclass.send(name)
              if superclass_value.nil?
                instance_variable_set("@#{name}", default)
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
              instance_variable_set("@#{name}", default)
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


        # if value != NoObject
        #   instance_variable_set("@#{name}", value)
        # end
        # if value == NoObject and instance_variable_get("@#{name}").nil?
        #   if superclass.respond_to?(name)
        #     parent_value = superclass.send(name)
        #     if parent_value.is_a?(Hash) || parent_value.is_a?(Array)
        #       instance_variable_set("@#{name}", parent_value.dup)
        #     else
        #       instance_variable_set("@#{name}", parent_value)
        #     end
        #   elsif default.present?
        #     instance_variable_set("@#{name}", default)
        #   else
        #     #
        #   end
        # end

        instance_variable_get("@#{name}")

        # unless default.nil? or send(attribute).present?
        #   if default.is_a?(Array) or default.is_a?(Hash)
        #     send("#{attribute}=", default.dup)
        #   else
        #     send("#{attribute}=", default)
        #   end
        # end
        #   send(attribute)
      end
      # send(attribute)
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
