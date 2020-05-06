class Forms::Ops::Config < Transactions::API

  schema do
    params do
      required(:route).value(inclusion?: Forms::Router.map.keys)
    end
  end

  pass :find_model
  step :validate_model
  step Policy::Pundit(Forms::Policy, :config?)

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:route])&.name, company_id: current_user.company_id)
  end

  def validate_model(context, model:, **)
    return on_error context, :base, 'Form not found' unless model.present?

    true
  end
end