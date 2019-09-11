class EventManager::Workflows::Create < Transactions::API

  step Model(EventWorkflow, :new)
  step Transactions::API::AssignModelUser(key: :user)
  step Policy::Pundit(EventManager::Workflows::Policy, :create?)
  step Contract::Build(constant: EventManager::Workflows::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Event created successfully')

end
