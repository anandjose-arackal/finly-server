module Forms
  module Definitions
    module DSL
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes
        class_attr :model
        class_attr :sections, default: []
      end

      module ClassMethods
        def section(key, &block)
          sections << Section.new(self, key, &block)
        end
      end
    end
  end
end