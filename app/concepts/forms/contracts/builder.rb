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
    properties << Forms::Contracts::Property.new(name, options, block, collection: false)
  end

  def self.build(user)
    form = self.form
    properties = self.properties
    klass = Class.new(Transactions::Contract) do
      properties.each do |prop|
        instance_eval &prop.build(form)
      end
    end
    klass.send :model, form.model if form.model
    klass
  end

end