class Masters::Schema::Ops::Show < Transactions::API

  step :find_model
  step Policy::Pundit(Masters::Schema::Policy, :show?)
  step :build_record_model
  step :resolve_dynamic_model

  def find_model(context, params:, current_user:, **)
    context[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: params[:id])
  end

  def build_record_model(context, model:, **)
    context[:record_model_class] = model.record_model_class
  end

  def resolve_dynamic_model(context, params:, record_model_class:, **)
    params[:model_class] = record_model_class
    Resolver::Transactions::Resolve.with(context, klass: Masters::Schema::Records::Resolver, paginate: true)
    true
  end

end