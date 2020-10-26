class Forms::Ops::Validations < Transactions::API

  step :find_form
  pass :init_system_validations
  pass :init_user_validations
  pass :merge_validations

  def find_form(context, params:, current_user:,**)
    result = Forms::Ops::Config.(params: params, current_user: current_user)
    return Transactions::API.on_schema_error(context, result.errors) unless result.success?

    context[:model] = result[:model]
    true
  end

  def init_system_validations(context, params:, **)
    form_klass = Forms::Router.klass(params[:route])
    context[:system_validations] = form_klass.validations
  end

  def init_user_validations(context, model:, **)
    context[:user_validations] = model.validations
  end

  def merge_validations(context, system_validations:, user_validations:, **)
    context[:validations] = []
    user_validation_ids = user_validations.map { |c| c.validation_id.to_s}
    system_validations.each_pair do |id, validation|
      context[:validations] << validation unless user_validation_ids.include?(id.to_s)
    end
    context[:validations] += user_validations
  end

end