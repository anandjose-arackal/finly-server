class Docs::P2P::Vendors::Update < Transactions::API

  step Form(route: 'vendors')
  step Model(YesBankVendor, :find_by)
  # step Policy::Pundit(Docs::P2P::Invoices::Policy, :create?)
  step Forms::Contracts::Build()

  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Updated')

end