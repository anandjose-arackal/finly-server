class Masters::Vendors::Ops::Show < Transactions::API

  step Model(YesBankVendor, :find_by_id)
  step Policy::Pundit(Masters::Vendors::Policy, :show?)

end