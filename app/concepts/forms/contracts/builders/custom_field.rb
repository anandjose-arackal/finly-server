class Forms::Contracts::Builders::CustomField

  def self.call(reform, custom_fields)
    reform.collection :custom_fields, deserializer: Forms::Contracts::Builders::CustomField::Build(custom_fields) do
      property :uuid
      property :form_entity_id
      property :entity_key
      property :value
      property :value_text
    end
  end

  def self.Build(custom_fields)
    -> (input, represented, **) do
      represented.custom_fields = []
      custom_fields.each do |custom_field_entity|
        custom_field = represented.custom_fields.find_by(field_id: custom_field_entity.uuid)
        if custom_field.nil?
          custom_field = FormCustomField.new(
              {
                  form_entity: custom_field_entity,
                  form_id: custom_field_entity.form_id,
                  entity_key: custom_field_entity.entity_key
              }
          )
        end
        if input[custom_field_entity.entity_key]
          custom_field.value = input[custom_field_entity.entity_key]
        end
        represented.custom_fields.append(custom_field)
      end
    end
  end
end