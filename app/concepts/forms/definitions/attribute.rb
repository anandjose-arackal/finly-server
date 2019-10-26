module Forms
  module Definitions
    module Attribute
      extend ActiveSupport::Concern

      module ClassMethods
        # Attribute is saved directly to the model and is comment for all types
        def attribute(key, default: nil)
          Entity::DEFAULT_SCHEMA[key] = default
          define_method key do |value = NoObject|
            self.schema_builder[key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema_builder[key])
          end
          alias_method "#{ key }=", key
        end

        def options
          @options || {}
        end

        # Options are type specific attributes
        def option(key, default: nil)
          options[key]
          define_method key do |value = NoObject|
            self.schema_builder[:options][key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema_builder[:options][key])
          end
          alias_method "#{ key }=", key
        end
      end
    end
  end
end