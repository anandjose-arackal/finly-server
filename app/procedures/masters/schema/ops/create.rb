class Masters::Schema::Ops::Create < Transactions::API

  # This if for custom schema creation
  # Todo : Creating the schema
  step Model(MasterSchema, :new)
  step Policy::Pundit(Masters::Schema::Policy, :create?)
  step Contract::Builder(constant: Masters::Schema::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end