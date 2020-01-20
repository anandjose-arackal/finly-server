class TaskManager::Workflows::Contracts::Schedule < TaskManager::Workflows::Contracts::Task

  property :trigger_type, validates: {presence: true, inclusion: {in: ['schedule']}}

end