class Forms::Contracts::Property

  attr_accessor :name, :options, :block, :collection, :parent, :path

  def initialize(name, options = {}, block, collection: false, parent: nil)
    self.name = name || raise('Name cannot be blank')
    self.options = options || {}
    self.block = block
    self.collection = collection
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
    properties << Forms::Contracts::Property.new(name, options, block, collection: false, parent: self)
  end

  def build(form)
    entity = form.find_entity(self.path)
    options = entity.options.deep_merge(self.options[:form])
    transformer = Forms::Contracts::Transformer.new(entity.field_key, options, contract_block(form))
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