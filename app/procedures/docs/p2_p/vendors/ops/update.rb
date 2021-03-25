class Docs::P2P::Vendors::Ops::Update < Transactions::API

  step Form(route: 'vendors')
  step Model(YesBankVendor, :find_by)
  step Policy::Pundit(Masters::Vendors::Policy, :update?)
  step Forms::Contracts::Build()

  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Updated')

end