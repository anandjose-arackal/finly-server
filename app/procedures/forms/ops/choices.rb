class Forms::Ops::Choices < Transactions::API

  schema do
    params do
      optional(:route) # Pointing to the form route
      optional(:form_record)
      optional(:form_data)
      optional(:row_data)
      required(:entity_path).filled
    end
  end

  # step Model(Form, :find_by_uuid)
  # step :find_form
  step :find_model
  step Policy::Pundit(Forms::Policy, :config?)
  step :init_entity
  pass :init_lookup_filters
  pass :init_choice_dependencies
  pass :scope_choices
  pass :scope_user
  pass :fetch

  def find_model(context, params:, current_user:, **)
    if params[:form_record].present?
      context[:model] = params[:form_record]
      context[:form] = context[:model].form_klass
    else
      context[:form] = Forms::Router.klass(params[:route])
      return on_error context, :base, "Invalid Route" if context[:form].blank?

      context[:model] = Form.find_by(model: context[:form].model, company_id: current_user.company_id)
      return false unless context[:model].present?
    end

    true
  end

  def init_entity(context, model:, params:, **)
    context[:entity] = model.find_entity(params[:entity_path])
    return on_error context, :base, "field not found" if context[:entity].blank?

    true
  end

  def init_lookup_filters(context, params:, current_user:, entity:, **)
    return unless entity.class.name == 'FormEntity::Lookup'
    return unless entity.filters.present?

    params[:qa] = entity.filters.as_ransack(data: {form: params[:form_data], row: params[:row_data]})
  end

  def init_choice_dependencies(context, model:, entity:, params:, **)
    return unless params[:form_data].present? or params[:row_data].present?

    controlling_choices = {}
    entity.choice_dependencies.includes(:controlling_entity).each do |dependency|
      value = Forms::RequestParser.new(form: params[:form_data], row: params[:row_data]).fetch(dependency.controlling_entity.entity_path)
      controlling_choices[dependency.controlling_entity.entity_path] = value
    end

    query = ''
    controlling_choices.each do |controlling_entity_path, value|
      query += " AND " unless query.blank?
      query += "(`form_entities`.`entity_path` = '#{controlling_entity_path}' AND controlling_choice_id = #{value})"
    end
    context[:dependency_mapping] = FormChoiceDependencyMapping
                                       .joins(dependency: :controlling_entity)
                                       .where("form_choice_dependencies.dependent_entity_id = '#{entity.id}'")
                                       .where(query)
  end

  def scope_choices(context, dependency_mapping: nil, params:, **)
    return unless dependency_mapping.present?

    choices = {}
    dependency_mapping.each do |mapping|
      choices[mapping.controlling_choice_id] = [] if choices[mapping.controlling_choice_id].blank?
      choices[mapping.controlling_choice_id] << mapping.dependent_choice_id
    end

    intersecting_choices = choices.values.first
    return if intersecting_choices.blank?

    choices.values.each do |arr|
      intersecting_choices = intersecting_choices & arr
    end
    context[:intersecting_choices] = intersecting_choices
    context[:filter_query] = {id_in: intersecting_choices}
  end

  # Pick the document owner. If the document is not created, pick the current_user
  def scope_user(context, model:, current_user:, **)
    # Assumption is that created_by is pointing to the document owner
    context[:user] = model.respond_to?(:created_by) ? model.created_by : current_user
  end

  def fetch(context, filter_query: nil, entity:, user:, params:, **)
    params[:q] = filter_query
    context[:choices] = entity.choices_scope.build(params: params, user: user)
  end

end