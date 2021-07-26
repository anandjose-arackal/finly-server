class Masters::Schema::Ops::Choices < Transactions::API

  step Policy::Pundit(Masters::Schema::Policy, :create?)
  pass :fetch

  def fetch(context, params:, current_user:, **)
    context[:choices] = Choices[:lookup].('master_schemas').build(params: params, user: current_user)

    true
  end

end