class Masters::Schema::Ops::Show < Transactions::API

  step Model(MasterSchema, :find_by_id)
  step Policy::Pundit(Masters::Schema::Policy, :show?)
  step :build_dynamic_model

  def build_dynamic_model(context, model, **)
    context[:dynamic_model] = model.dynamic_model
  end

  def resolve_dynamic_model(context, dynamic_model:, **)
    Resolver::Transactions::Resolve.with(context, klass: Masters::Schema::DynamicModel::Resolver, paginate: true)
  end

end