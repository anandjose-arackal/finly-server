class Forms::Ops::Index < Transactions::API

  pass :find_models
  step Policy::Pundit(Forms::Policy, :index?)

  def find_models(context, params:, current_user:, **)
    context['model.index'] = Form.where.not(klass_name: nil).where(company_id: current_user.company_id).reject(&:import_form?)
  end
end