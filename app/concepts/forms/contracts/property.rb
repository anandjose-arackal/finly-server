class Forms::Contracts::Property

  attr_accessor :name, :options, :block, :is_collection, :parent, :path

  def initialize(name, options = {}, block, collection: false, parent: nil)
    self.name = name || raise('Name cannot be blank')
    self.options = options || {}
    self.block = block
    self.is_collection = collection
    self.parent = parent
    self.path = self.parent.present? ? "#{parent.path}_#{self.name}" : "#{self.name}"

    instance_eval &block if self.block.present?
  end

  def properties
    @properties ||= []
  end

  def property(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: false, parent: self)
  end

  def collection(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: true, parent: self)
  end

  def build(form)
    entity = form.find_entity(self.path)
    if entity
      entity_options = entity.schema
      entity_options = entity_options.deep_merge(self.options[:form]) if self.options[:form]
    else
      entity_options = self.options[:form] || {}
    end
    transformer = Forms::Contracts::Transformer.new(name, entity_options, self.options.except(:form), contract_block(form), collection: is_collection)
    transformer.generate
  end

  def contract_block(form)
    return nil unless properties.present?

    properties = self.properties
    lambda do |*args|
      properties.each do |prop|
        instance_eval &prop.build(form)
      end
    end
  end

end