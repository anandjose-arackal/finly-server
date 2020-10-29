class Forms::ChoiceDependencies::Ops::Index < Transactions::API

  schema do
    params do
      required(:form_id).filled
    end
  end

  step Policy::Pundit(Forms::Policy, :index?)
  pass :find_models

  step :check_success

  def check_success(ctx, options)
    true
  end

  def find_models(context, params:, current_user:, **)
    context['model.index'] = FormChoiceDependency.where(company_id: current_user.company_id, form_id: params[:form_id])
  end
end