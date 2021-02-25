module MlModels::Schema
  extend ActiveSupport::Concern

  class_methods do
    def schema_validation(&block)
      @schema_validation = SchemaValidation.build(&block) if block_given?
      @schema_validation ||= SchemaValidation.build
    end

    def schema
      @schema ||= { options: {}, config: {} }
    end

    def configs
      @configs ||= {}.with_indifferent_access
    end

    def config(key, default: NoObject)
      configs[key] = { key: key, default: default }
      schema[:config][key] = default unless default == NoObject
    end

  end

  def set(attribute, value, args: nil)
    val = Transactions::Evaluator.eval_proc(self, value, args)
    if self.class.configs[attribute].present?
      self.config ||= {}
      self.config[attribute.to_s] = val
    else
      self.send("#{attribute}=", val)
    end
  end

  def schema
    attributes
  end

  def valid_schema?
    validator = schema_validation.new
    result = validator.call(schema)
    if result.failure?
      return Failure(result.errors.to_h)
    end
    Success()
  end

  def schema_validation
    self.class.schema_validation
  end

  class SchemaValidation

    def self.build(&block)
      Class.new(Dry::Validation::Contract) do
        params do
          instance_exec &block if block_given?
        end
      end
    end

  end

end