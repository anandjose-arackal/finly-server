class EventManager::Workflows::Show < Transactions::API

  step Model(EventWorkflow, :find)
  step Policy::Pundit(EventManager::Workflows::Policy, :show?)

end
