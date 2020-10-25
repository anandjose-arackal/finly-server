class Forms::Ops::Config < Transactions::API

  # schema do
  #   params do
  #     required(:route).value(included_in?: Forms::Router.map.keys)
  #   end
  # end

  step :validate_route
  pass :find_model
  step :validate_model
  step Policy::Pundit(Forms::Policy, :config?)

  def validate_route(options, params:, **)
    unless Forms::Router.map.keys.include?(params[:route])
      add_message(options, :error, :invoice, "Invalid Route")
      return
    end
    true
  end

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:route])&.name, company_id: current_user.company_id)
  end

  def validate_model(context, model:, **)
    return on_error context, :base, 'Form not found' unless model.present?

    true
  end
end