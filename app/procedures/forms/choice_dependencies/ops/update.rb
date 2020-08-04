class Forms::ChoiceDependencies::Ops::Update < Transactions::API


  step Model(FormChoiceDependency, :find_by_uuid)

  step Policy::Pundit(Forms::ChoiceDependencies::Policy, :update?)

  step Contract::Build(builder: :build_contract)


  step Contract::Validate(key: :form_choice_dependency)

  step Contract::Persist()

  step :check_success
  fail :check_failure

  # Helper methods
  def check_success(ctx, options)
    debugger
    true
  end
  def check_failure(ctx, options)
    true
    debugger
  end


  def build_contract(options, model:, current_user:, **)
    Forms::ChoiceDependencies::Contracts::Base.new(model, current_user: current_user)
    # model.class.contract(model, current_user: current_user)
  end
end