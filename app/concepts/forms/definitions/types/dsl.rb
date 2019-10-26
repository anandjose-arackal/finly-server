module Forms
  module Definitions
    module Types
      module DSL
        extend ActiveSupport::Concern

        def self.types
          @types ||= {}
        end

        def entities
          @entities ||= []
        end

        def entity(*args, &block)
          opts = args.extract_options!
          klass, name = klass_and_name_from args
          parent = (is_a?(Entity) ? self : nil)
          entities << klass.new(section, parent, name, opts, &block)
        end

        def klass_and_name_from(args)
          type, name = args
          if DSL.types[type]
            [DSL.types[type], name]
          else
            [Entity, type]
          end
        end

        module ClassMethods
          def register(type)
            self.registered_type = type
            DSL.types[type] = self

            DSL.module_eval do
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
end
