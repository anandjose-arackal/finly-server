class Forms::Ops::Choices < Transactions::API

  schema do
    params do
      required(:route).filled # Pointing to the form route
      optional(:controlling_choices)
      required(:entity_path).filled
    end
  end

  # step Model(Form, :find_by_uuid)
  step :find_form
  step :find_model
  step Policy::Pundit(Forms::Policy, :config?)
  step :init_entity
  pass :init_choice_dependencies
  pass :scope_choices
  pass :scope_user
  pass :fetch

  def find_form(context, params:, **)
    context[:form] = Forms::Router.klass(params[:route])
    return on_error context, :base, "Invalid Route" if context[:form].blank?

    true
  end

  def find_model(context, params:, form:, current_user:, **)
    context[:model] = Form.find_by(model: form.model, company_id: current_user.company_id)
    return false unless context[:model].present?

    true
  end

  def init_entity(context, model:, params:, **)
    context[:entity] = model.entities.find_by(entity_path: params[:entity_path])
    if context[:entity].blank?
      return on_error context, :base, "field not found"
    end

    true
  end

  def init_choice_dependencies(context, model:, entity:, params:, **)
    return unless params[:controlling_choices].present?

    query = ''
    params[:controlling_choices].each do |controlling_entity_path, value|
      query += " AND " unless query.blank?
      query += "(`form_entities`.`entity_path` = '#{controlling_entity_path}' AND controlling_choice_id = #{value})"
    end
    context[:choice_dependency_mapping] = FormChoiceDependencyMapping.joins(dependency: :controlling_entity)
                                              .where("form_choice_dependencies.dependent_entity_id = '#{entity.id}'")
                                              .where(query)
    # context[:choice_dependencies] = model.choice_dependencies.joins(:mapping)
    #                                     .where(query)
    #                                     .ransack(form_entity: entity)
    #                                     .result
    #                                     .includes(:controlling_entity, :mappings)
  end

  def scope_choices(context, choice_dependency_mapping: nil, params:, **)
    return unless choice_dependency_mapping.present?

    choices = {}
    choice_dependency_mapping.each do |mapping|
      choices[mapping.controlling_choice_id] = [] if choices[mapping.controlling_choice_id].blank?
      choices[mapping.controlling_choice_id] << mapping.dependent_choice_id
    end

    # choice_dependencies.each do |dependency|
    #   choices[dependency] = []
    #   dependency.rules.each do |rule|
    #     if rule.match?(params[:controlling_choices])
    #       choices[dependency] += dependency.mappings.map { |map| map.form_entity_choice_id }
    #     end
    #   end
    # end
    intersecting_choices = choices.values.first
    return if intersecting_choices.blank?

    choices.values.each do |arr|
      intersecting_choices = intersecting_choices & arr
    end
    context[:filter_query] = {id_in: intersecting_choices}
  end

  # Pick the document owner. If the document is not created, pick the current_user
  def scope_user(context, current_user:, **)
    # Todo: Scope user based on document owner and use current user as a fallback
    context[:user] = current_user
  end

  def fetch(context, filter_query: nil, entity:, user:, **)
    params = {q: filter_query}
    context[:choices] = entity.choices_scope.build(params: params, user: user)
  end

end