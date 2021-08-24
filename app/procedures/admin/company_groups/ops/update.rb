class Admin::CompanyGroups::Ops::Update < Admin::Transactions::API

  step Model(CompanyGroup, :find_by_id)
  step Policy::Pundit(Admin::CompanyGroups::Policy, :update?)
  # step AssignAdminModelUser(key: :created_by_admin)
  step Contract::Build(constant: Admin::CompanyGroups::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Organisation updated')

end