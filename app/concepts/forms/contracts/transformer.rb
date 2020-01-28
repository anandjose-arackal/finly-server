class Forms::Contracts::Transformer
  attr_accessor :field_name, :entity_options, :property_options, :block

  def initialize(field_name, entity_options, property_options, block)
    self.field_name = field_name
    self.entity_options = entity_options
    self.property_options = property_options
    self.block = block
  end

  def contract_validations
    validations = {validates: [], validate: []}
    entity_options.each do |option, value|
      transformer = Forms::Contracts::Transformers::Registry.for(option)&.new(field_name, value)
      next unless transformer

      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end

    entity_options[:options]&.each do |option, value|
      transformer = Forms::Contracts::Transformers::Registry.for(option)&.new(field_name, value)
      next unless transformer

      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end
    validations
  end

  def generate
    transformer = self
    lambda do |*args|
      if transformer.block
        property transformer.field_name, transformer.property_options, &transformer.block
      else
        property transformer.field_name, transformer.property_options
      end
      validations = transformer.contract_validations
      validations[:validates].each do |val|
        validates *val
      end

      validations[:validate].each do |val|
        validate val
      end
    end
  end

end