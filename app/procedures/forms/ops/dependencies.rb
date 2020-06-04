class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_dependencies
  pass :init_conditions
  pass :init_validations
  pass :init_computations
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

  def init_computations(context, model:, dependencies:, **)
    dependencies[:computations] = []
    model.entities.where(compute_enabled: true).includes(:compute_lookup_entity, :parent).each do |entity|
      computation = {entity_path: entity.entity_path, config_path: entity.config_path, type: entity.compute_type.name}
      if entity.parent.present? and entity.parent.class.collection?
        computation[:collection] = {
            entity_key: entity.parent.entity_key,
            config_path: entity.parent.config_path
        }
      end
      if entity.compute_lookup?

        computation[:lookup_entity_path] = entity.compute_lookup_entity.entity_path
      elsif entity.compute_form?
        computation[:formula] = entity.compute_formula
      end
      dependencies[:computations] << computation
    end
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