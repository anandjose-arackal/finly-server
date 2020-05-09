module Forms::API::Entity::Schema
  extend ActiveSupport::Concern

  DEFAULT_SYSTEM_SCHEMA = {
      entity_path: ->(*args) { self.entity_key&.to_s },
      label: ->(*args) { self.entity_key&.to_s&.humanize },
      placeholder: "Enter value",
      entity_type: ->(*args) { self.class.registered_type },
      editable: true,
      required: false,
      active: true,
      unique: false,
      visible: true,
      custom_field: false,
      internal: false,
      is_modified: false,
      can_visible_be_changed: false,
      can_editable_be_changed: false,
      can_required_be_changed: false,
      can_uniqueness_be_changed: false,
      can_be_disabled: false,
      can_label_be_renamed: true,
      can_choices_be_changed: true,
      allow_clearing_default_value: true,
      options: {},
      config: {}
  }

  class_methods do

    def schema_validation(&block)
      @schema_validation = SchemaValidation.build(&block) if block_given?
      @schema_validation ||= SchemaValidation.build
    end

    def schema
      @schema ||= {options: {}, config: {}}
    end

    def options
      @options ||= {}.with_indifferent_access
    end

    def configs
      @configs ||= {}.with_indifferent_access
    end

    def option(key, default: NoObject)
      options[key] = {key: key, default: default}
      schema[:options][key] = default unless default == NoObject
    end

    def config(key, default: NoObject)
      configs[key] = {key: key, default: default}
      schema[:config][key] = default unless default == NoObject
    end

    def set(attribute, value)
      if options[attribute].present?
        schema[:options][attribute] = value
      elsif configs[attribute].present?
        schema[:config][attribute] = value
      else
        schema[attribute] = value
      end
    end
  end

  def set(attribute, value)
    val = Transactions::Evaluator.eval_proc(self, value)
    if self.class.options[attribute].present?
      self.options[attribute] = val
    elsif self.class.configs[attribute].present?
      self.config[attribute] = val
    else
      self.send("#{attribute}=", val)
    end
  end

  def schema
    attributes.merge(section: section)
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
          required(:section).filled
          required(:entity_key).filled
          required(:entity_path).filled
          required(:label).filled
          required(:placeholder).filled
          optional(:hint)
          required(:entity_type).filled
          optional(:default_value)
          required(:editable).value(:bool?)
          required(:required).value(:bool?)
          optional(:active).filled(:bool?)
          optional(:unique).filled(:bool?)
          optional(:visible).filled(:bool?)
          optional(:position).filled(:int?)
          optional(:custom_field).filled(:bool?)
          optional(:can_visible_be_changed).filled(:bool?)
          optional(:can_editable_be_changed).filled(:bool?)
          optional(:can_required_be_changed).filled(:bool?)
          optional(:can_uniqueness_be_changed).filled(:bool?)
          optional(:can_be_disabled).filled(:bool?)
          optional(:can_label_be_renamed).filled(:bool?)
          optional(:can_choices_be_changed).filled(:bool?)
          optional(:allow_clearing_default_value).filled(:bool?)

          optional(:choices).array do
            hash do
              optional(:id)
              required(:value).filled
              required(:position).value(:int?)
              required(:active).value(:bool?)
            end
          end
          instance_exec &block if block_given?
        end
      end
    end

  end

end