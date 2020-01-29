class Docs::Trips::Ops::Update < Transactions::API

  step Model(Trip, :find_by_uuid)
  step Policy::Pundit(Docs::Trips::Policies::Actions, :update?)
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()
  step Messages::Task::SuccessMessage("Trip saved")

  def build_contract(context, model:, current_user:, **)
    Docs::Trips::Contracts::Create.build(current_user).new(model)
  end

end