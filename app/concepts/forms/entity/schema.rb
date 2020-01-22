module Forms
  module Entity
    module Schema
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes

        class_attr :schema, default: {}
      end

      class_methods do
        # def schema
        #   return @class_schema if @class_schema
        #
        #   if self == Entity
        #     @class_schema ||= {}
        #   else
        #     @class_schema ||= Entity.schema.deep_dup
        #   end
        # end

        # Attribute is saved directly to the model and is comment for all types
        def attribute(key, default: nil)
          schema[key] = default
          define_method key do |value = NoObject|
            self.schema_builder[key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema_builder[key])
          end
          alias_method "#{ key }=", key

          define_singleton_method key do |value = NoObject|
            schema[key] = value unless value == NoObject
            schema[key]
          end
        end

        # Options are type specific attributes
        def option(key, default: nil)
          define_method key do |value = NoObject|
            self.schema_builder[:options][key] = value unless value == NoObject
            Transactions::Helper.execute_if_proc(self, schema_builder[:options][key])
          end
          alias_method "#{ key }=", key

          define_singleton_method key do |value = NoObject|
            schema[:options][key] = value unless value == NoObject
            schema[:options][key]
          end
        end

        def consumes_choices?
          @consumes_choices ||= false
        end

        def consumes_choices!
          @consumes_choices = true
        end

      end

      def schema_builder
        @schema_builder ||= self.class.schema.deep_dup.merge(options: {})
      end

      def schema
        return @schema if @schema

        @schema = {options: {}}
        schema_builder.except(:options).keys.each do |key|
          @schema[key] = self.send(key)
        end

        schema_builder[:options].keys.each do |key|
          @schema[:options][key] = self.send(key)
        end

        if self.class.consumes_choices? and schema_builder[:choices].present?
          @schema[:choices] = schema_builder[:choices].build
        end

        @schema
      end

      def choices(values = NoObject)
        return nil unless self.class.consumes_choices?

        @choices ||= []
        unless values == NoObject
          @choice_position ||= 0
          values.each do |value|
            value = {value: value} if value.is_a?(String)
            value[:id] = nil
            value[:active] = true
            value[:position] = @choice_position
            @choices << value
            @choice_position += 1
          end
        end
        @choices
      end

      alias_method :choices=, :choices

      def auto_complete(route: nil, filters: {})
        return nil unless self.class.consumes_choices?

        @auto_complete = {route: route, filters: filters} if route
        @auto_complete
      end

      alias_method :auto_complete=, :auto_complete
    end
  end
end