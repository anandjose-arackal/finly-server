class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_dependencies
  pass :init_computations

  def find_form(context, params:, current_user:,**)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_dependencies(context, model:, **)
    context[:dependencies] = {conditions: model.conditions, validations: model.validations, choice_dependencies: []}
  end

  def init_computations(context, model:, **)
    context[:dependencies][:computations] = []
    model.entities.where(compute_enabled: true).includes(:compute_lookup_entity).each do |entity|
      computation = {entity_path: entity.entity_path, type: entity.compute_type.name}
      if entity.compute_lookup?

        computation[:lookup_entity_path] = entity.compute_lookup_entity.entity_path
      elsif entity.compute_form?
        computation[:formula] = entity.compute_formula
      end
      context[:dependencies][:computations] << computation
    end
  end

end