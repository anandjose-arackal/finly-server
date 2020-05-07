module Forms::Generators::Contracts::ModelHelpers::FormEntity

  def contract_property_options
    property_options = {}
    # In-case of custom fields, create a virtual field which is used for validations and dependencies
    if custom_field
      entity = self
      property_options[:virtual] = true
      # property_options[:deserializer] = -> (input, represented, **) do
      #   associated_cf = represented.custom_fields.find {|custom_field| custom_field.form_entity_id == entity.uuid}
      #   represented.send("#{entity.entity_key}=", (associated_cf.value))
      # end
    end

    if populate_if_empty.present? and not property_options[:populate_if_empty]
      property_options[:populate_if_empty] = populate_if_empty
    end
    property_options
  end

  def contract
    is_collection = (entity_type == "collection")
    builder_args = [self, entity_key, schema, contract_property_options, contract_block, collection: is_collection]
    transformer = Forms::Generators::Contracts::EntityBuilder.new(*builder_args)
    transformer.generate
  end

  def contract_block
    return nil unless entities.present?

    entity = self
    entities = self.entities

    lambda do |*args|
      instance_eval &Forms::Generators::Contracts::EntityBuilder::CustomField.setup(entities.custom_fields) if entity.associate_custom_fields

      entities.each do |entity|
        instance_eval &entity.contract
      end
    end
  end
end