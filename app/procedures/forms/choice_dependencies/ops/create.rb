class Forms::ChoiceDependencies::Ops::Create < Transactions::API

  step Model(FormChoiceDependency, :new)

  step Policy::Pundit(Forms::ChoiceDependencies::Policy, :create?)

  step Contract::Build(builder: :build_contract)

  step Contract::Validate(key: :form_choice_dependency)

  step :check_success

  step Contract::Persist()

  fail :check_failure

  # Helper methods
  def check_success(ctx, options)
    debugger
    true
  end
  def check_failure(ctx, options)
    true
  end

  def build_contract(options, model:, current_user:, **)
    Forms::ChoiceDependencies::Contracts::Base.new(model, current_user: current_user)
    # model.class.contract(model, current_user: current_user)
  end
end