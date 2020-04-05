form = @op["model"]
form.sections.each do |section|
  json.set! section.name do
    json.array! section.entities.exclude_internal do |entity|
      json.id entity.uuid
      json.field_key entity.field_key
      json.label entity.label
      json.placeholder entity.placeholder
      json.hint entity.hint
      json.field_type entity.field_type
      json.default_value entity.default_value
      json.editable entity.editable
      json.required entity.required
      json.active entity.active
      json.visible entity.visible
      json.unique entity.unique
      json.position entity.position
      json.custom_field entity.custom_field
      json.options entity.options
      if entity.choices_provider.present?
        json.choices entity.choices_provider.as_json(params: @op["params"], user: @op["current_user"] )
      end
    end
  end
end