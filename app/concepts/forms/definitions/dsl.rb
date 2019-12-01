module Forms
  module Definitions
    module DSL
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes
        include ClassMethods
        # class_attr :model
        class_attr :sections, default: []
      end

      module ClassMethods

        def model(value = NoObject)
          unless value == NoObject
            @model = value
            raise "Form is already defined for model #{value}" if Forms::API[value.to_s].present?

            Forms::API[value.to_s] = self
          end
          @model
        end

        def section(name, &block)
          sections << Section.new(self, name, &block)
        end

        def collection(name, &block)
          sections << Collection.new(self, name, &block)
        end
      end
    end
  end
end