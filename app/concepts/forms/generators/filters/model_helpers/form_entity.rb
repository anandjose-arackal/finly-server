module Forms::Generators::Filters::ModelHelpers::FormEntity

  def entity_type_klass
    Forms::Entity::Registry.types[entity_type]
  end

  def operators
    entity_type_klass.operators
  end

  def filter_form(options = {})
    filter = {
        label: label,
        hint: hint,
        type: entity_type,
        filter_key: entity_path.gsub("/", "_"),
        operators: operators,
        multiple: multiple
    }
    if entity_type_klass.consumes_choices?
      filter[:scope] = scope.as_json
    end
    if entity_type_klass.consumes_choices?
      filter[:choices] = choices.as_json
    end
    filter
  end

end