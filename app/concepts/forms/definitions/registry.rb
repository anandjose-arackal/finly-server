module Forms
  module Definitions
    module Registry
      extend ActiveSupport::Concern

      def self.types
        @types ||= {}.with_indifferent_access
      end

      def entities
        @entities ||= []
      end

      def entity(*args, &block)
        opts = args.extract_options!
        klass, name = klass_and_name_from args
        entity = klass.new(section, name, opts, &block)
        entity.custom_field(false)
        result = entity.valid?
        unless result.success?
          raise "Invalid Form Field: #{self.form}##{name} (#{klass}) Failure: #{result.failure.to_json}"
        end
        entities << entity
      end

      def klass_and_name_from(args)
        type, name = args
        if Registry.types[type]
          [Registry.types[type], name]
        else
          [Entity, type]
        end
      end

      module ClassMethods
        def register(type)
          self.registered_type = type
          Registry.types[type] = self

          Registry.module_eval do
            define_method type do |*args, &block|
              opts = args.extract_options!
              name = args.first
              @position ||= 0
              entity type, name, opts.merge(position: @position), &block
              @position += 1
            end
          end
        end
      end
    end
  end
end
