class Companies::Ops::Update < Transactions::API

  step Model(Company, :find_by_id)
  # step Transactions::API::AssignModelUser(key: :created_by)
  step Policy::Pundit(Companies::Policy, :update?)
  step Contract::Build(constant: Companies::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Messages::Task::SuccessMessage("Company updated")

end