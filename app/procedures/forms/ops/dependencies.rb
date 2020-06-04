class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_dependencies
  pass :init_conditions
  pass :init_validations
  pass :init_form_computations
  pass :init_lookup_computations
  pass :init_lookup_filters
  pass :init_choice_dependencies

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
    dependencies[:conditions] = model.conditions
  end

  def init_validations(context, model:, dependencies:, **)
    dependencies[:validations] = model.validations
  end

  def init_form_computations(context, model:, dependencies:, **)
    dependencies[:form_computations] = []
    model.entities.where(compute_enabled: true, compute_type_id: FormEntityComputationType.id_for(:form)).includes(:compute_lookup_entity, :parent).each do |entity|
      computation = {entity_path: entity.entity_path, config_path: entity.config_path, type: entity.compute_type.name}
      if entity.parent.present? and entity.parent.class.collection?
        computation[:collection_entity_key] = entity.parent.entity_key
        computation[:collection_config_path] = entity.parent.config_path
      end
      computation[:formula] = entity.compute_formula
      dependencies[:form_computations] << computation
    end
  end

  def init_lookup_computations(context, model:, dependencies:, **)
    lookup_computations = {}
    model.entities.where(
        compute_enabled: true,
        compute_type_id: FormEntityComputationType.id_for(:lookup))
        .includes(:compute_lookup_entity, :parent).each do |entity|
      lookup_computations[entity.compute_lookup_entity.entity_path] ||= {
          lookup_entity_path: entity.compute_lookup_entity.entity_path,
          lookup_config_path: entity.compute_lookup_entity.config_path,
          dependent_entities: []
      }
      lookup_computations[entity.compute_lookup_entity.entity_path][:dependent_entities] << {
          entity_path: entity.entity_path,
          config_path: entity.config_path
      }
    end
    dependencies[:lookup_computations] = lookup_computations.values
  end

  def init_lookup_filters(context, dependencies:, model:, **)
    dependencies[:lookup_filters] = model.entities.where.not(filters: nil).map do |entity|
      {
          entity_path: entity.entity_path,
          filters: entity.filters.as_ransack
      }
    end
  end

  def init_choice_dependencies(context, model:, dependencies:, **)
    dependencies[:choice_dependencies] = model.choice_dependencies.includes(:mappings).map do |choice_dependency|
      {
          controlling_entity: {
              entity_key: choice_dependency.controlling_entity.entity_key,
              entity_path: choice_dependency.controlling_entity.entity_path,
              config_path: choice_dependency.controlling_entity.config_path,
          },
          dependent_entity: {
              entity_key: choice_dependency.dependent_entity.entity_key,
              entity_path: choice_dependency.dependent_entity.entity_path,
              config_path: choice_dependency.dependent_entity.config_path,
          },
      }
    end
  end


end