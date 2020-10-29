class Masters::Schema::Ops::Update < Masters::Schema::Ops::Base

  # Todo : Updating the schema
  step FindMasterSchema()
  step Policy::Pundit(Masters::Schema::Policy, :update?)
  step Contract::Build(constant: Masters::Schema::Contract)
  step Contract::Validate()
  step Contract::Persist()
  # step Masters::Schema::Ops::MigrationRunner::Build()
  step Transactions::Messages::SuccessMessage('Saved')


end