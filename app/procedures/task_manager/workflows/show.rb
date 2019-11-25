class TaskManager::Workflows::Show < Transactions::API

  step Model(TaskWorkflow, :find_by_uuid)
  step Policy::Pundit(TaskManager::Workflows::Policy, :show?)

end
