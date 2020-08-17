class Masters::Schema::Ops::Create < Transactions::API

  # This if for custom schema creation
  # Todo : Creating the schema
  step Model(MasterSchema, :new)
  step AssignModelUser()
  step Policy::Pundit(Masters::Schema::Policy, :create?)
  step Contract::Build(constant: Masters::Schema::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Masters::Schema::Ops::MigrationRunner::Build()
  step Transactions::Messages::SuccessMessage('Saved')

end