class Forms::Contracts::Builder
  include DynamicAttributes

  class_attr :form

  def self.properties
    @properties ||= []
  end

  def self.property(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: false)
  end

  def self.collection(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: true)
  end

  def self.functions(&block)
    @functions = block if block_given?
    @functions
  end

  def self.build(user)
    form = self.form
    properties = self.properties
    functions = self.functions
    klass = Class.new(Transactions::Contract) do
      properties.each do |prop|
        instance_eval &prop.build(form)
      end

      class_eval &functions if functions.present?
    end
    klass.send :model, form.model if form.model
    klass
  end

end