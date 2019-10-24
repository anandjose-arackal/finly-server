module Forms
  module Definitions
    module DSL
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes
        class_attr :model
        class_attr :sections, default: []
      end

      class_methods do
        def section(key, &block)
          sections << Section.new(key, &block)
        end
      end
    end
  end
end