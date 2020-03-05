class Forms::Ops::Choices < Transactions::API

  schema do
    params do
      required(:id).filled
      optional(:controlling_entity_values).array do
        hash do
          required(:controlling_entity_id).filled
          required(:controlling_choice_id).filled
        end
      end
      required(:entity_id).filled
    end
  end

  step Model(Form, :find_by_uuid)
  step Policy::Pundit(Forms::Policy, :config?)
  step :init_entity
  pass :init_dependency_mappings
  pass :scope_choices
  pass :fetch

  def init_entity(context, model:, params:, **)
    context[:entity] = model.entities.find_by(uuid: params[:entity_id])
    if context[:entity].blank?
      return on_error context, :base, "field not found"
    end

    true
  end

  def init_dependency_mappings(context, params:, model:, **)
    controlling_entity_values = params[:controlling_entity_values]
    if controlling_entity_values.present?
      query = build_query(controlling_entity_values)
      context[:dependency_choice_mappings] = FormDependencyChoiceMapping.where(query)
    end
  end

  def scope_choices(context, dependency_choice_mappings: [], **)
    context[:q] = {}
    return if dependency_choice_mappings.count == 0

    map = {}
    dependency_choice_mappings.each do |mapping|
      map[mapping.controlling_entity_id] ||= []
      map[mapping.controlling_entity_id] << mapping.dependent_choice_id
    end
    intersecting_choices = nil
    map.values.each do |value_arr|
      intersecting_choices ||= value_arr
      intersecting_choices = intersecting_choices & value_arr
    end
    context[:q] = {id_in: intersecting_choices}
  end

  def fetch(context, q:, entity:, current_user:, **)
    context[:values] = entity.scope.values(filter: q, user: current_user)
  end

  protected
  def build_query(values)
    query = ""
    values.each do |map|
      query += " OR " if query.present?
      query += "(controlling_entity_id = #{map[:controlling_entity_id]} AND controlling_choice_id = #{controlling_choice_id})"
    end
    query
  end

end