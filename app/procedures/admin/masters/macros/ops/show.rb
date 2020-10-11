class Admin::Masters::Macros::Ops::Show < Admin::Transactions::API

  step Model(Macro, :find_by_id)
  step Policy::Pundit(Admin::Masters::Macros::Policy, :show?)

end