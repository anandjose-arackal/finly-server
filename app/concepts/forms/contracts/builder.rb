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
    form = self.form.fetch(user)
    properties = self.properties
    functions = self.functions
    entities_map = {}
    form.entities.includes(:entities).each {|e| entities_map[e.field_path] = e }
    klass = Class.new(Forms::Contract) do
      class_eval &functions if functions.present?

      properties.each do |prop|
        class_eval &prop.build(form, entities_map)
      end

      form.dependencies.each do |dependency|
        class_eval &dependency.contract
      end
    end
    klass.send :model, form.model if form.model
    klass
  end

end