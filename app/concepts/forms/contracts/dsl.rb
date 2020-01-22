module Forms::Contracts::DSL
  extend ActiveSupport::Concern

  class_methods do
    def contract(&block)
      @contract = Forms::Contracts::EntityContract.build(&block) if block_given?
      @contract ||= Forms::Contracts::EntityContract.build
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