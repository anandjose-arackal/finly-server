class Forms::Generators::Contracts::API::Property

  attr_accessor :name, :options, :block, :is_collection, :parent, :path, :builder

  def initialize(builder, name, options = {}, block, collection: false, parent: nil)
    self.builder = builder
    self.name = name || raise('Name cannot be blank')
    self.options = options || {}
    self.block = block
    self.is_collection = collection
    self.parent = parent
    self.path = self.parent.present? ? "#{parent.path}/#{self.name}" : "#{self.name}"

    instance_eval &block if self.block.present?
  end

  def properties
    @properties ||= []
  end

  def property(name, options = {}, &block)
    properties << Forms::Generators::Contracts::API::Property.new(builder, name, options, block, collection: false, parent: self)
  end

  def collection(name, options = {}, &block)
    properties << Forms::Generators::Contracts::API::Property.new(builder, name, options, block, collection: true, parent: self)
  end

  def build(form, entities_map)
    entity = entities_map[self.path]
    if entity
      entity_options = entity.schema
      entity_options = entity_options.deep_merge(self.options[:form]) if self.options[:form]
    else
      entity_options = self.options[:form] || {}
    end

    contract_property_options = entity&.contract_property_options || {}
    contract_property_options.merge(options.except(:form))

    transformer = Forms::Generators::Contracts::EntityBuilder.new(
        entity,
        name,
        entity_options,
        contract_property_options,
        contract_block(form, entity, entities_map),
        collection: is_collection
    )
    transformer.generate
  end

  def contract_block(form, entity, entities_map)
    return nil unless properties.present?

    properties = self.properties
    load_custom_fields = builder.load_custom_fields?
    lambda do |*args|

      if load_custom_fields and entity&.entities.custom_fields.present?
        instance_eval &Forms::Generators::Contracts::EntityBuilder::CustomField.setup(entity.entities.custom_fields)

        # Load custom fields from form
        entity.entities.custom_fields.each do |custom_field_entity|
          instance_eval &custom_field_entity.contract
        end
      end

      properties.each do |prop|
        instance_eval &prop.build(form, entities_map)
      end
    end
  end

end