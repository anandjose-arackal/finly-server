class TaskManager::Workflows::Index < Transactions::API

  step Transactions::Resolver::Load(model: TaskWorkflow, scope: :default, filter: true, paginate: true)

end
