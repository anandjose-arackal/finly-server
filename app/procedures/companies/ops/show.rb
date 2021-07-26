class Companies::Ops::Show < Transactions::API

  step Model(Company, :find_by_id)
  step Policy::Pundit(Companies::Policy, :show?)

end