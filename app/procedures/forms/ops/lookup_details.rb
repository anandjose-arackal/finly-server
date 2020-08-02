class Forms::Ops::LookupDetails < Transactions::API

  schema do
    params do
      required(:route).value(included_in?: Forms::Router.map.keys)
      required(:entity_path).filled
      required(:value).filled
    end
  end

  step :find_model
  step Policy::Pundit(Forms::Policy, :config?)
  step :find_entity
  step :find_record
  pass :find_dependent_entities
  pass :compute

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:route])&.name, company_id: current_user.company_id)
    return on_error context, :base, 'Form not found' unless context[:model].present?

    true
  end

  def find_entity(context, model:, params:, **)
    context[:entity] = model.entities.find_by(entity_path: params[:entity_path])
    return on_error context, :base, 'Error in request' unless context[:entity].present?

    true
  end

  def find_record(context, entity:, params:, current_user:, **)
    context[:entity_record] = entity.choices_scope.find_by_id(params[:value], params: params, user: current_user)
    context[:entity_exposure] = context[:entity_record]&.to_exposure
    return on_error context, :base, 'Error in request' unless context[:entity_exposure].present?

    true
  end

  def find_dependent_entities(context, model:, entity:, **)
    context[:dependent_entities] = model.entities.where(compute_lookup_entity: entity)
  end

  def compute(context, entity_exposure:, dependent_entities:, **)
    context[:data] = data = {}
    dependent_entities.each do |dep_ent|
      data[dep_ent.entity_path] = entity_exposure.template(dep_ent.compute_formula)
    end
  end

end