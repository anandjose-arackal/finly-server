class TaskManager::Triggers::Schedule::Contract < TaskManager::Workflows::Contract

  property :trigger_type, validates: {presence: true, inclusion: {in: ['schedule']}}

end