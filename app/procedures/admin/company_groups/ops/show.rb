class Admin::CompanyGroups::Ops::Show < Admin::Transactions::API

  step Model(CompanyGroup, :find_by_id)
  step Policy::Pundit(Admin::CompanyGroups::Policy, :show?)

end