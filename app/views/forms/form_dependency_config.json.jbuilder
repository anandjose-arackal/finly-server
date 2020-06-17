form = @op["model"]
json.data do
  json.array! form.dependencies do |dependency|
    json.controlling_entity do
      json.id dependency.controlling_entity_id
      json.key dependency.controlling_entity_key
    end
    json.dependent_entity do
      json.id dependency.dependent_entity_id
      json.key dependency.dependent_entity_key
    end
    json.dependency_mappings do
      json.array! dependency.dependency_mappings do |mapping|
        json.controlling_choice_id mapping.controlling_choice_id
        json.dependent_required mapping.dependent_required
        json.dependent_visible mapping.dependent_visible
        json.dependent_editable mapping.dependent_editable
        json.has_dependent_choices mapping.has_dependent_choices
        json.lazy_load_dependent_choices mapping.lazy_load_dependent_choices
        if mapping.has_dependent_choices and not mapping.lazy_load_dependent_choices
          json.dependent_choices do
            json.array! mapping.dependency_choice_mappings.pluck(:dependent_choice_id)
          end
        end
      end
    end
  end
end