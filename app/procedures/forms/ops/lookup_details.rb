class Forms::Ops::LookupDetails < Transactions::API

  schema do
    params do
      required(:route).filled #.value(included_in?: Forms::Router.map.keys)
      required(:entity_path).filled
      required(:value).filled
      optional(:assignments) # Registers is used for lookup
    end
  end

  step :find_model
  step Policy::Pundit(Forms::Policy, :config?) # Todo
  step :find_entity
  step :find_record
  pass :find_dependent_entities
  pass :compute_nested
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
    context[:all_data] = []
    true
  end

  def compute_nested(context, params:, model:, entity_exposure:, dependent_entities:, current_user:, **)
    nested_data = {}
    
    dependent_entities = context[:dependent_entities]
    dependent_entities.each do |entity|
      nested_dependent_entities = model.entities.where(compute_lookup_entity: entity)
      parent_key = entity.entity_key.to_s
      
      if nested_dependent_entities.present?
        value = entity_exposure.template(entity.compute_formula, registers: params.dig(:assignments, entity.entity_path))
        entity_path = entity.entity_path
        params_hash = params.merge!({value: value, entity_path: entity&.entity_path})

        new_data = Forms::Ops::LookupDetails.(params: params_hash, current_user: current_user) || {}
        nested_data.merge!(new_data[:data] || {} )
      end
    end
    context[:all_data] = nested_data
    true
  end

  def compute(context, params:, entity_exposure:, dependent_entities:, **)
    context[:data] = data = {}
    dependent_entities.each do |dep_ent|
      data[dep_ent.entity_path] = entity_exposure.template(dep_ent.compute_formula, registers: params.dig(:assignments, dep_ent.entity_path))
      if dep_ent.entity_path.split("_").include?("id")
        data["#{dep_ent.entity_path}_value"] = entity_exposure.template(dep_ent.compute_formula.gsub('id', 'value'), registers: params.dig(:assignments, dep_ent.entity_path))
      end
    end

    data.merge!(context[:all_data])
    data
  end  

end