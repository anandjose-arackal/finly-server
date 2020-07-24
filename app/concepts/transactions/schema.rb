class Transactions::Schema < Dry::Validation::Contract

  def self.Validate(constant:)
    Transactions::Task.build id: "schema.validate", after: "operations.start" do |context, **|
      Validate.with(context, constant: constant)
    end
  end

  class Validate
    def self.with(context, name: :params, constant:)
      schema_validator = constant.new
      return Transactions::API.on_error(context, :base, 'Unable to validate the request') if schema_validator.nil?
      result = schema_validator.call(context[name])
      unless result.success?
        return Transactions::API.on_schema_error(context, result.errors)
      end
      true
    end
  end

  module Transactions::Schema::DSL

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Fixme: Limitation -> The validation is supported only for incoming `params`. Since multiple arguments are supported for the params, such as current user, we should allow validations against all arguments instead of just the params
      def schema(&block)
        klass = Class.new(Transactions::Schema)
        klass.instance_eval &block
        step Transactions::Schema::Validate(constant: klass)
      end
    end

  end

end