class Forms::Contracts::CustomField

  def self.setup(custom_fields)
    lambda do |*args|
      collection :custom_fields, deserializer: Forms::Contracts::CustomField::Build(custom_fields) do
        property :uuid
        property :form_entity_id
        property :field_key
        property :value
        property :value_text
      end
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
                  field_key: custom_field_entity.field_key
              }
          )
        end
        if input[:custom_fields]&.dig(custom_field_entity.uuid)
          custom_field.value = input[:custom_fields]&.dig(custom_field_entity.uuid)
        end
        represented.custom_fields.append(custom_field)
      end
    end
  end

end