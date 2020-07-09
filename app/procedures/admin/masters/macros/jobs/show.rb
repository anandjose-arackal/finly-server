class Admin::Masters::Macros::Jobs::Show < Admin::Transactions::API

  step Model(MacroJob, :find_by_id)
  step Policy::Pundit(Admin::Masters::Macros::Jobs::Policy, :show?)

end