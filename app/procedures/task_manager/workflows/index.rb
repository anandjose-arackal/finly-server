class TaskManager::Workflows::Index < Transactions::API

  step Resolver::Transactions::Load(model: TaskWorkflow, scope: :default, filter: true, paginate: true)

end
