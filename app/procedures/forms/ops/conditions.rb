class Forms::Ops::Conditions < Transactions::API

  step :find_form
  pass :init_system_conditions
  pass :init_user_conditions
  pass :merge_conditions

  def find_form(context, params:, current_user:,**)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_system_conditions(context, params:, **)
    form_klass = Forms::Router.klass(params[:route])
    context[:system_conditions] = form_klass.conditions
  end

  def init_user_conditions(context, model:, **)
    context[:user_conditions] = model.conditions
  end

  def merge_conditions(context, system_conditions:, user_conditions:, **)
    context[:conditions] = []
    user_condition_ids = user_conditions.map { |c| c.condition_id.to_s}
    system_conditions.each_pair do |id, condition|
      context[:conditions] << condition unless user_condition_ids.include?(id.to_s)
    end
    context[:conditions] += user_conditions
  end

end