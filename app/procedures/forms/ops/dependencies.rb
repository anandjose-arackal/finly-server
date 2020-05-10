class Forms::Ops::Dependencies < Transactions::API

  step :find_form
  pass :init_dependencies

  def find_form(context, params:, current_user:,**)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_dependencies(context, model:, **)
    context[:dependencies] = {conditions: model.conditions, validations: model.validations, choice_dependencies: []}
  end

end