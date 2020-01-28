class Forms::Contracts::Transformer
  attr_accessor :field_name, :options, :block

  def initialize(field_name, options, block)
    self.field_name = field_name
    self.options = options
    self.block = block
  end

  def contract_validations
    validations = {validates: [], validate: []}
    options.each do |option, value|
      transformer = Forms::Contracts::Transformers::Registry.for(option)&.new(field_name, value)
      next unless transformer

      validations[:validates] += transformer.validates
      validations[:validate] += transformer.validate
    end

    options[:options]&.each do |option, value|
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
        property transformer.field_name, {}, &transformer.block
      else
        property transformer.field_name, {}
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