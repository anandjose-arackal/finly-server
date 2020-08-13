class Admin::Masters::Macros::Ops::Destroy < Admin::Transactions::API

  step Model(Macro, :find_by_id)
  step Policy::Pundit(Admin::Masters::Macros::Policy, :destroy?)
  step ModelDestroy()
  step Transactions::Messages::SuccessMessage('Macro Deleted')

end