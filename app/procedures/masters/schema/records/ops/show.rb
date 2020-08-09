class Masters::Schema::Records::Ops::Create < Masters::Schema::Records::Base

  schema do
    params do
      required(:master_key).filled
    end
  end

  # This is defined in base class
  step RecordModel(:new)
  step Policy::Pundit(Masters::Schema::Records::Policy, :create?)
  step AssignModelUser(key: :created_by)
  step Masters::Schema::Records::Contract::Build()
  step Contract::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end