class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_system_dependencies
  pass :init_user_dependencies
  pass :init_dependencies
  pass :merge_conditions
  pass :merge_validations

  def find_form(context, params:, current_user:,**)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_system_dependencies(context, params:, **)
    form_klass = Forms::Router.klass(params[:route])
    context[:system_conditions] = form_klass.conditions
    context[:system_validations] = form_klass.validations
    # context[:choice_dependencies] = form_klass.choice_dependencies
  end

  def init_user_dependencies(context, model:, **)
    context[:user_conditions] = model.conditions
    context[:user_validations] = model.validations
  end

  def init_dependencies(context, options)
    context[:dependencies] = {conditions: [], validations: [], choice_dependencies: []}
  end

  def merge_conditions(context, dependencies:, system_conditions:, user_conditions:, **)
    user_condition_ids = user_conditions.map { |c| c.condition_id.to_s}
    system_conditions.each_pair do |id, condition|
      dependencies[:conditions] << condition unless user_condition_ids.include?(id.to_s)
    end
    dependencies[:conditions] += user_conditions
  end

  def merge_validations(context, dependencies:, system_validations:, user_validations:, **)
    user_validation_ids = user_validations.map { |c| c.validation_id.to_s}
    system_validations.each_pair do |id, validation|
      dependencies[:validations] << validation unless user_validation_ids.include?(id.to_s)
    end
    dependencies[:validations] += user_validations
  end

end