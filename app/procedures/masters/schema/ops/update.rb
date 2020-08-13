class Masters::Schema::Ops::Update < Transactions::API

  # Todo : Updating the schema
  step FindMasterSchema()
  step Policy::Pundit(Masters::Schema::Policy, :update?)
  step Contract::Builder(constant: Masters::Schema::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end