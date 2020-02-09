module Forms::Generators::Filters::ModelHelpers::FormEntity

  def field_type_klass
    Forms::API::Entity::Registry.types[field_type]
  end

  def filter_options
    field_type_klass.filters
  end

  def filter_form(options = {})
    filter = {
        label: label,
        hint: hint,
        type: field_type,
        filter_key: field_path,
        options: filter_options,
        multiple: multiple
    }
    if field_type_klass.consumes_choices?
      filter[:scope] = scope
    end
    filter
  end

end