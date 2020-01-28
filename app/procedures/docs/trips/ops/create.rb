class Docs::Trips::Ops::Create < Transactions::API

  step Model(Trip, :new)
  step Transactions::API::AssignModelUser(key: :created_by)
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  # pass -> (context, options) {debugger}
  step Contract::Persist()
  step Messages::Task::SuccessMessage("Trip saved")

  def build_contract(context, model:, current_user:, **)
    Docs::Trips::Contracts::Create.build(current_user).new(model)
  end

end