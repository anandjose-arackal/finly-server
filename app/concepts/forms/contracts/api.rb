class Forms::Contracts::API
  include DynamicAttributes

  class_attr :form

  def self.properties
    @properties ||= []
  end

  def self.property(name, options = {}, &block)
    properties << Forms::Contracts::API::Property.new(self, name, options, block, collection: false)
  end

  def self.collection(name, options = {}, &block)
    properties << Forms::Contracts::API::Property.new(self, name, options, block, collection: true)
  end

  def self.load_custom_fields!
    @load_custom_fields = true
  end

  def self.load_custom_fields?
    @load_custom_fields ||= false
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
    form.entities.includes(:entities).each { |e| entities_map[e.field_path] = e }
    root_custom_fields = form.entities.root.custom_fields
    load_custom_fields = load_custom_fields?
    klass = Class.new(Forms::Contract) do
      class_eval &functions if functions.present?

      if load_custom_fields and root_custom_fields.present?
        instance_eval &Forms::Contracts::EntityBuilder::CustomField.setup(root_custom_fields)

        # Load custom fields from form
        root_custom_fields.each do |custom_field_entity|
          instance_eval &custom_field_entity.contract
        end
      end


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