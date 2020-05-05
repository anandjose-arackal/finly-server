class Forms::Ops::Choices < Transactions::API

  schema do
    params do
      required(:form_name).filled
      optional(:controlling_entity_values).array do
        hash do
          required(:controlling_entity_key).filled
          required(:controlling_choice_id).filled
        end
      end
      required(:entity_field_key).filled
    end
  end

  # step Model(Form, :find_by_uuid)
  step :find_model
  step Policy::Pundit(Forms::Policy, :config?)
  step :init_entity
  pass :init_dependency_mappings
  pass :scope_choices
  pass :scope_user
  pass :fetch

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.find_by(model: params[:form_name], company_id: current_user.company_id)
    return false unless context[:model].present?

    true
  end

  def init_entity(context, model:, params:, **)
    context[:entity] = model.entities.find_by(field_key: params[:entity_field_key])
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
    context[:filter_query] = {}
    return if dependency_choice_mappings.count == 0

    map = {}
    dependency_choice_mappings.each do |mapping|
      map[mapping.controlling_entity_key] ||= []
      map[mapping.controlling_entity_key] << mapping.dependent_choice_id
    end
    intersecting_choices = nil
    map.values.each do |value_arr|
      intersecting_choices ||= value_arr
      intersecting_choices = intersecting_choices & value_arr
    end
    context[:filter_query] = {id_in: intersecting_choices}
  end

  # Pick the document owner. If the document is not created, pick the current_user
  def scope_user(context, current_user:, **)
    # Todo: Scope user based on document owner and use current user as a fallback
    context[:user] = current_user
  end

  def fetch(context, filter_query:, entity:, user:, **)
    params = {q: filter_query}
    context[:choices] = entity.choices_scope.as_json(params: params, user: user)
  end

  protected
  def build_query(values)
    query = ""
    values.each do |map|
      query += " OR " if query.present?
      query += " (`form_dependency_choice_mappings`.`controlling_entity_key` = '#{map[:controlling_entity_key]}' AND `form_dependency_choice_mappings`.`controlling_choice_id` = '#{map[:controlling_choice_id]}')"
    end
    query
  end

end