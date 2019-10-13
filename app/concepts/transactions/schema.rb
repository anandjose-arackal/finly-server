class Transactions::Schema < Dry::Validation::Contract

  def self.Validate(constant:)
    step = ->(input, options) {Validate.with(input, options, constant: constant)}
    [step, {name: "schema.validate", after: "operations.start"}]
  end

  class Validate
    def self.with(input, options, name: :params, constant:)
      schema_validator = constant.new
      return Transactions::API.on_error(input, :base, 'Unable to validate the request') if schema_validator.nil?

      result = schema_validator.call(options&.dig(name))
      unless result.success?
        return Transactions::API.on_schema_error(input, result.errors)
      end
      true
    end
  end

  module Transactions::Schema::DSL

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def schema(&block)
        klass = Class.new(Transactions::Schema)
        klass.instance_eval &block
        step *Transactions::Schema::Validate(constant: klass)
      end
    end

  end

end