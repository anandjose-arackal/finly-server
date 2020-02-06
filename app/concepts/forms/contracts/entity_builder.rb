class Forms::Contracts::EntityBuilder
  attr_accessor :field_name, :entity_options, :contract_property_options, :block, :collection, :entity

  def initialize(entity, field_name, entity_options, contract_property_options, block, collection: false)
    self.entity = entity
    self.field_name = field_name
    self.entity_options = entity_options || {}
    self.contract_property_options = contract_property_options || {}
    self.block = block
    self.collection = collection
  end

  def contract_validations
    # Setters: Executed first to set all the values. This will ensure all values are set before the validations are run. Ex: Define
    # validates: name, validation_config
    # validate: Proc used to define validations
    validations = {validates: [], validate: [], setters: []}
    entity_options.each do |option, value|
      transformer = Forms::Contracts::EntityBuilder::Validations::Registry.for(option)&.new(entity, field_name, value)
      next unless transformer

      validations[:setters] += transformer.setters
      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end

    entity_options[:options]&.each do |option, value|
      transformer = Forms::Contracts::EntityBuilder::Validations::Registry.for(option)&.new(entity, field_name, value)
      next unless transformer

      validations[:setters] += transformer.setters
      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end
    validations
  end

  def generate
    transformer = self
    lambda do |*args|
      function = transformer.collection ? :collection : :property
      if transformer.block
        send function, transformer.field_name, transformer.contract_property_options, &transformer.block
      else
        send function, transformer.field_name, transformer.contract_property_options
      end
      validations = transformer.contract_validations
      validations[:setters].each do |val|
        validate val
      end

      validations[:validate].each do |val|
        validate val
      end

      validations[:validates].each do |val|
        validates *val
      end
    end
  end

end