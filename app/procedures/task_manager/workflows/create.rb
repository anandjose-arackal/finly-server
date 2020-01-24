class TaskManager::Workflows::Create < Transactions::API

  step Model(TaskWorkflow, :new)
  step Transactions::API::AssignModelUser(key: :user)
  step Policy::Pundit(TaskManager::Workflows::Policy, :create?)
  step Contract::Build(constant: TaskManager::Workflows::Contracts::Task)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Task created successfully')

end
