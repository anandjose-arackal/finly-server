class TaskManager::Workflows::Show < Transactions::API

  step Model(TaskWorkflow, :find)
  step Policy::Pundit(TaskManager::Workflows::Policy, :show?)

end
