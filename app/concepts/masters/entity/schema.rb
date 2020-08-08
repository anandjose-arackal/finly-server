module Masters::Entity::Schema
  extend ActiveSupport::Concern

  class_methods do
    def build_schema_contract(system: false)
      base_class = system ? Masters::Entity::Contract::System : Masters::Entity::Contract::Custom

      schema_contract = self.schema_contract
      return base_class unless schema_contract.present?
      Class.new(base_class) do
        instance_exec &schema_contract
      end
    end

    def schema_contract(&block)
      @schema_contract = block if block_given?
      @schema_contract
    end

    def schema
      @schema ||= {options: {}}.with_indifferent_access
    end

    def options
      @options ||= {}.with_indifferent_access
    end

    def option(key, default: NoObject)
      options[key] = {key: key, default: default}
      schema[:options][key] = default unless default == NoObject
    end

    def set(attribute, value)
      if options[attribute].present?
        schema[:options][attribute] = value
      else
        schema[attribute] = value
      end
    end
  end

  def schema_contract
    # system_entity is a database attribute of master_entity
    self.class.build_schema_contract(system: system_entity)
  end

end