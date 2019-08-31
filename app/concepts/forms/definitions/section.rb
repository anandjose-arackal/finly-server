class Forms::Definitions::Section
  attr_accessor :key, :options, :block, :section, :parents, :parent

  def initialize(key, options = {}, &block)
    self.section = self
    self.key = key
    self.options = options
    self.block = block
    self.parents = [] if self.parents.nil?
    instance_eval &block if block.present?
  end

  def parents_association
    []
  end

  def properties
    @properties ||= []
  end

  def validations
    @validations ||= {validate: [], validates: [], validates_with: []}
  end
  
  def property(key, options = {}, &block)
    properties << Forms::Definitions::Property.new(section, parents_association, key, options, &block)
  end

  def collection(key, options = {}, &block)
    properties << Forms::Definitions::Types::CollectionType.new(section, parents_association, key, options, &block)
  end

  def amount(key, options = {}, &block)
    properties << Forms::Definitions::Types::AmountType.new(section, parents_association, key, options, &block)
  end

  def string(key, options = {}, &block)
    properties << Forms::Definitions::Types::StringType.new(section, parents_association, key, options, &block)
  end

  def text(key, options = {}, &block)
    properties << Forms::Definitions::Types::TextType.new(section, parents_association, key, options, &block)
  end

  def integer(key, options = {}, &block)
    properties << Forms::Definitions::Types::IntegerType.new(section, parents_association, key, options, &block)
  end

  def decimal(key, options = {}, &block)
    properties << Forms::Definitions::Types::DecimalType.new(section, parents_association, key, options, &block)
  end

  def dropdown(key, options = {}, &block)
    properties << Forms::Definitions::Types::DropdownType.new(section, parents_association, key, options, &block)
  end

  def checkbox(key, options = {}, &block)
    properties << Forms::Definitions::Types::CheckboxType.new(section, parents_association, key, options, &block)
  end

  def radio_button(key, options = {}, &block)
    properties << Forms::Definitions::Types::RadioButtonType.new(section, parents_association, key, options, &block)
  end

  def date(key, options = {}, &block)
    properties << Forms::Definitions::Types::DateType.new(section, parents_association, key, options, &block)
  end

  def lookup(key, options = {}, &block)
    properties << Forms::Definitions::Types::LookupType.new(section, parents_association, key, options, &block)
  end

  def multi_select(key, options = {}, &block)
    properties << Forms::Definitions::Types::MultiSelectType.new(section, parents_association, key, options, &block)
  end

  def formula(key, options = {}, &block)
    properties << Forms::Definitions::Types::FormulaType.new(section, parents_association, key, options, &block)
  end

  def validate(*args, &block)
    validations[:validate] << Forms::Definitions::Validation.new(*args, &block)
  end

  def validates(*args, &block)
    validations[:validates] << Forms::Definitions::Validation.new(*args, &block)
  end

  def validates_with(*args, &block)
    validations[:validates_with] << Forms::Definitions::Validation.new(*args, &block)
  end

end