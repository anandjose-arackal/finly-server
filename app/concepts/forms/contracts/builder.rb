class Forms::Contracts::Builder
  include DynamicAttributes

  class_attr :form

  def self.properties
    @properties ||= []
  end

  def self.validations
    @validations ||= {validates: [], validate: []}
  end

  def self.validates(name, validation)
    validations[:validates] << [name, validation]
  end

  def self.validate(validation)
    validations[:validates] << validation
  end

  def self.property(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: false)
  end

  def self.collection(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: true)
  end

  def self.build(user)
    form = self.form
    properties = self.properties
    validations = self.validations
    klass = Class.new(Transactions::Contract) do
      properties.each do |prop|
        instance_eval &prop.build(form)
      end
      validations[:validates].each do |validation|
        validates *validation
      end

      validations[:validate].each do |validation|
        validate validation
      end
    end
    klass.send :model, form.model if form.model
    klass
  end

end