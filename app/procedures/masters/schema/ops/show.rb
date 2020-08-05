class Masters::Schema::Ops::Show < Transactions::API

  step :find_model
  step Policy::Pundit(Masters::Schema::Policy, :show?)
  step :build_dynamic_model
  step :resolve_dynamic_model

  def find_model(context, params:, current_user:, **)
    context[:model] = MasterSchema.find_by(company_id: current_user.company_id, table_name: params[:id])
  end

  def build_dynamic_model(context, model:, **)
    context[:dynamic_model] = model.dynamic_model
  end

  def resolve_dynamic_model(context, params:, **)
    params[:dynamic_model] = context[:dynamic_model]
    Resolver::Transactions::Resolve.with(context, klass: Masters::Schema::DynamicModel::Resolver, paginate: true)
    true
  end

end