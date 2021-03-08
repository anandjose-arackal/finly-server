class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_dependencies
  pass :init_conditions
  pass :init_validations
  pass :init_form_computations
  pass :init_lookup_computations
  pass :init_lookup_filters
  pass :init_choice_dependencies
  pass :init_predictions

  def find_form(context, params:, current_user:, **)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_dependencies(context, model:, **)
    context[:dependencies] = {}
  end

  def init_conditions(context, dependencies:, model:, **)
    dependencies[:conditions] = model.conditions.includes(:referencable_entity).where(form_entities: { internal: false })
  end

  def init_validations(context, model:, dependencies:, **)
    dependencies[:validations] = model.validations.includes(:form_entity).where(form_entities: { internal: false })
  end

  def init_form_computations(context, model:, dependencies:, **)
    dependencies[:form_computations] = []
    model.entities.where(internal: false, compute_enabled: true, compute_type_id: FormEntityComputationType.id_for(:form)).includes(:compute_lookup_entity, :parent).each do |entity|
      computation = entity.form_reference_json
      computation[:type] = entity.compute_type.name
      computation[:formula] = entity.compute_formula
      dependencies[:form_computations] << computation
    end
  end

  def init_lookup_computations(context, model:, dependencies:, **)
    dependencies[:lookup_computations] = []
    model.entities.where(
      internal: false,
      compute_enabled: true,
      compute_type_id: FormEntityComputationType.id_for(:lookup))
         .includes({ compute_lookup_entity: :parent }, :parent).each do |entity|
      json = entity.form_reference_json
      lookup_json = entity.compute_lookup_entity.form_reference_json
      lookup_json.each_pair do |key, value|
        json["lookup_#{key}"] = value
      end
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

end