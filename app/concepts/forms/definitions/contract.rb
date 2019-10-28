module Forms
  module Definitions
    class Contract
      attr_accessor :field_key, :opts, :block

      def initialize(field_key, opts = {}, &block)
        self.field_key = field_key
        self.opts = opts
        self.block = block
      end

      def contract
        self.class.contract
      end

      module DSL
        extend ActiveSupport::Concern

        module ClassMethods
          def contract(&block)
            @contract = EntityContract.build(&block) if block_given?
            @contract ||= EntityContract.build
          end

          def valid_schema?(schema)
            contract = self.contract.new
            result = contract.call(schema)
            if result.failure?
              return Failure(result.errors.to_h)
            end
            Success(schema)
          end
        end

        def valid?
          self.class.valid_schema?(self.schema)
        end
      end
    end
  end
end