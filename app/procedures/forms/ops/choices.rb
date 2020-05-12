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

  def init_choice_dependencies(context, model:, entity:, **)
    context[:choice_dependencies] = model.choice_dependencies
                                        .ransack(form_entity: entity)
                                        .result
                                        .includes(:rules, :mappings)
  end

  def scope_choices(context, choice_dependencies:, params:, **)
    return if choice_dependencies.size == 0

    choices = {}
    choice_dependencies.each do |dependency|
      choices[dependency] = []
      dependency.rules.each do |rule|
        if rule.match?(params[:controlling_choices])
          choices[dependency] += dependency.mappings.map { |map| map.form_entity_choice_id }
        end
      end
    end
    intersecting_choices = choices.values.first
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