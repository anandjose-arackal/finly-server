class Forms::Contracts::Transformer
  attr_accessor :field_name, :entity_options, :property_options, :block, :collection, :entity

  def initialize(entity, field_name, entity_options, property_options, block, collection: false)
    self.entity = entity
    self.field_name = field_name
    self.entity_options = entity_options || {}
    self.property_options = property_options || {}
    self.block = block
    self.collection = collection
    setup_property_options
  end

  def setup_property_options
    return unless entity

    entity = self.entity

    if entity.custom_field
      property_options[:virtual] = true
      property_options[:deserializer] = -> (input, represented, **) do
        associated_cf = represented.custom_fields.find { |custom_field| custom_field.form_entity_id == entity.uuid }
        represented.send("#{entity.field_key}=", (associated_cf.value))
      end
    end

    if entity.populate_if_empty.present? and not self.property_options[:populate_if_empty]
      self.property_options[:populate_if_empty] = entity.populate_if_empty
    end
  end

  def contract_validations
    # Setters: Executed first to set all the values. This will ensure all values are set before the validations are run. Ex: Define
    # validates: name, validation_config
    # validate: Proc used to define validations
    validations = {validates: [], validate: [], setters: []}
    entity_options.each do |option, value|
      transformer = Forms::Contracts::Transformers::Registry.for(option)&.new(entity, field_name, value)
      next unless transformer

      validations[:setters] += transformer.setters
      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end

    entity_options[:options]&.each do |option, value|
      transformer = Forms::Contracts::Transformers::Registry.for(option)&.new(entity, field_name, value)
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
        send function, transformer.field_name, transformer.property_options, &transformer.block
      else
        send function, transformer.field_name, transformer.property_options
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