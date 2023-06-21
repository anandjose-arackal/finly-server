class Forms::Ops::Dependencies < Transactions::API

  step :init_performance_toggle
  step :find_form
  pass :init_dependencies
  pass :init_conditions
  pass :init_validations
  pass :init_form_computations
  pass :init_lookup_computations
  pass :init_lookup_filters
  pass :init_lookup_assignments
  pass :init_triggers
  pass :init_choice_dependencies
  pass :init_predictions
  pass :init_section_positions

  def init_performance_toggle(context, params:, current_user:, **)
    context[:better_performance_enabled] = DependenciesPerformanceToggle.new(current_user).enabled?
    true
  end

  def find_form(context, params:, current_user:, **)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_dependencies(context, model:, **)
    context[:dependencies] = {}
  end

  def init_conditions(context, dependencies:, model:, better_performance_enabled:, **)
    unless better_performance_enabled
      dependencies[:conditions] = model.conditions.includes(:referencable_entity).where(form_entities: {internal: false})
      return true
    end

    dependencies[:conditions] = model.conditions.includes(:referencable_entity, :actions).where(form_entities: {internal: false})
  end

  def init_validations(context, model:, dependencies:, **)
    dependencies[:validations] = model.validations.includes(:form_entity).where(form_entities: {internal: false})
  end

  def init_form_computations(context, model:, dependencies:, **)
    dependencies[:form_computations] = []
    model.entities.where(compute_enabled: true, compute_type_id: FormEntityComputationType.id_for(:form)).includes(:compute_type, :compute_lookup_entity, :parent).each do |entity|
      computation = entity.form_reference_json
      computation[:type] = entity.compute_type.name
      computation[:formula] = entity.compute_formula
      dependencies[:form_computations] << computation
    end
  end

  def init_lookup_computations(context, model:, dependencies:, **)
    dependencies[:lookup_computations] = []
    model.entities.where(
      compute_enabled: true,
      compute_type_id: FormEntityComputationType.id_for(:lookup))
         .includes({ compute_lookup_entity: :parent }, :parent).each do |entity|
      json = entity.form_reference_json
      lookup_json = entity.compute_lookup_entity&.form_reference_json
      lookup_json.each_pair do |key, value|
        json["lookup_#{key}"] = value
      end
      json['assignments'] = entity.compute_lookup_assignments
      dependencies[:lookup_computations] << json
    end
  end

  def init_lookup_filters(context, dependencies:, model:, **)
    dependencies[:lookup_filters] = model.entities.where.not(filters: nil).map do |entity|
      json = entity.form_reference_json
      json[:filters] = entity.filters.as_ransack
      json
    end
  end

  def init_lookup_assignments(context, dependencies:, model:, better_performance_enabled:, **)

    unless better_performance_enabled
      dependencies[:lookup_assignments] = []
      model.entities.each do |entity|
        json = entity.form_reference_json
        json['assignments'] = {}
        model.entities.where(compute_lookup_entity: entity).where.not(compute_lookup_assignments: nil).each do |dependent_entity|
          json['assignments'][dependent_entity.entity_path] = dependent_entity.compute_lookup_assignments
        end

        next unless json['assignments'].present?

        dependencies[:lookup_assignments] << json
      end
      return true
    end


    dependencies[:lookup_assignments] = []
    child_compute_lookup_entities = FormEntity.includes(:parent, :compute_lookup_entity).where(compute_lookup_entity_id: [model.entities]).where.not(compute_lookup_assignments: nil)

    main_entities = {}
    child_compute_lookup_entities.each do |dependent_entity|
      unless main_entities.key? dependent_entity.compute_lookup_entity_id
        main_entities[dependent_entity.compute_lookup_entity_id] = dependent_entity.compute_lookup_entity.form_reference_json
        main_entities[dependent_entity.compute_lookup_entity_id]['assignments'] = {}
      end

      main_entities[dependent_entity.compute_lookup_entity_id]['assignments'][dependent_entity.entity_path] = dependent_entity.compute_lookup_assignments
    end

    main_entities.each do|key, value|
      Rails.logger.debug value
      if value['assignments'].present?
        dependencies[:lookup_assignments] << value
      end
    end
  end

  def init_triggers(context, dependencies:, model:, **)
    dependencies[:triggers] = []
    model.entities.where.not(triggers: nil).each do |entity|
      if entity.triggers.present?
        json = entity.form_reference_json
        json[:triggers] = entity.triggers
        dependencies[:triggers] << json
      end
    end
  end

  def init_choice_dependencies(context, model:, dependencies:, **)
    dependencies[:choice_dependencies] = model.choice_dependencies.includes(:mappings, { controlling_entity: :parent }, { dependent_entity: :parent }).map do |choice_dependency|
      {
        controlling_entity: choice_dependency.controlling_entity.form_reference_json,
        dependent_entity: choice_dependency.dependent_entity.form_reference_json
      }
    end
  end

  def init_predictions(context, model:, dependencies:, current_user:, **)
    return unless FormsToggle.new(current_user).enabled?

    dependencies[:predictions] = []
    model.entities
         .includes(prediction_model: { dependent_entity_mappings: [:form_entity] })
         .each do |entity|
      next if entity.prediction_model.blank?

      dependencies[:predictions] << {
        target_entity: entity.entity_path,
        dependent_entities: entity.prediction_model.dependent_entity_mappings.map { |mapping|
          mapping.form_entity.entity_path
        }
      }
    end
  end

  def init_section_positions(context, dependencies:, model:, **)
    dependencies[:section_positions] = []
    position = 0
    model.sections.where.not(section_id: ['status', 'attachments']).sort_by(&:created_at).each do |section|
      position_details = { 
        section_key: section.section_id,
        position: position,
        display_name: section.display_name,
      }
      position += 1
      dependencies[:section_positions] << position_details
    end
    dependencies[:section_positions]
  end

end