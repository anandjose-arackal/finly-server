class Admin::CompanyGroups::Ops::Create < Admin::Transactions::API

  step Model(CompanyGroup, :new)
  step Policy::Pundit(Admin::CompanyGroups::Policy, :create?)
  # step AssignAdminModelUser(key: :created_by_admin)
  step Contract::Build(constant: Admin::CompanyGroups::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Organisation created')

end