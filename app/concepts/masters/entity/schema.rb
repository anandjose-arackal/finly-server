module Masters::Entity::Schema
  extend ActiveSupport::Concern

  class_methods do

    def schema_contract(system: false)
      base_class = system ? Masters::Entity::Contract::System : Masters::Entity::Contract::Custom

      return base_class
    end

    def schema
      @schema ||= {}
    end

    def set(attribute, value)
      schema[attribute] = value
    end
  end

  def schema_contract
    # system_entity is a database attribute of master_entity
    self.class.schema_contract(system: system_entity)
  end

end