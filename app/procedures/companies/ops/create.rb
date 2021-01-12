class Companies::Ops::Create < Transactions::API

  step Model(Company, :new)
  # step Transactions::API::AssignModelUser(key: :created_by)
  step Policy::Pundit(Companies::Policy, :create?)
  step Contract::Build(constant: Companies::Contract)
  step Contract::Validate()
  step :set_company_group!
  step Contract::Persist()
  step Messages::Task::SuccessMessage("Company created")

  def set_company_group!(options, model:, current_user:, **)
    model.group_id = current_user.company.group.id
  end

end