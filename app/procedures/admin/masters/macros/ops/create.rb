class Admin::Masters::Macros::Ops::Create < Admin::Transactions::API

  step Model(Macro, :new)
  step Policy::Pundit(Admin::Masters::Macros::Policy, :create?)
  step AssignAdminModelUser(key: :created_by_admin)
  step Contract::Build(constant: Admin::Masters::Macros::Contracts::Macro)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Macro Saved')

end