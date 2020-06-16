class Forms::Ops::Config < Transactions::API

  schema do
    params do
      required(:name).value(inclusion?: Forms::Router.forms.map {|form| form.model.to_s.underscore})
    end
  end

  pass :find_model
  step :validate_model
  step Policy::Pundit(Forms::Policy, :config?)

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.find_by(model: params[:name], company_id: current_user.company_id)
  end

  def validate_model(context, model:, **)
    return on_error context, :base, 'Form not found' unless model.present?

    true
  end
end