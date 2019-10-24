module Forms
  module Definitions
    module Attribute
      extend ActiveSupport::Concern

      module ClassMethods
        # Attribute is saved directly to the model and is comment for all types
        def attribute(key, opts = {})
          Entity::DEFAULT_SCHEMA[key] = opts[:default] if opts[:default]
          define_method key do |value = NoObject|
            self.schema[key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema[key])
          end
          alias_method "#{ key }=", key
        end

        # Options are type specific attributes
        def option(key, opts = {})
          Entity::DEFAULT_SCHEMA[:options][key] = opts[:default] if opts[:default]
          define_method key do |value = NoObject|
            self.schema[:options][key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema[:options][key])
          end
          alias_method "#{ key }=", key
        end
      end
    end
  end
end