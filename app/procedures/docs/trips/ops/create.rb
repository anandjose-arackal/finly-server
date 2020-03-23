class Docs::Trips::Ops::Create < Transactions::API

  step Model(Trip, :new)
  step Transactions::API::AssignModelUser(key: :created_by)
  step Policy::Pundit(Docs::Trips::Policies::Actions, :create?)
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()
  step Messages::Task::SuccessMessage("Trip saved")

  def build_contract(context, model:, current_user:, **)
    # Docs::Trips::Form.fetch(current_user).contract.new(model)
    Docs::Trips::Contracts::Create.build(current_user).new(model)
  end


end