class EventManager::Triggers::Schedule::Contract < EventManager::Workflows::Contract

  property :trigger_type, validates: {presence: true, inclusion: {in: ['schedule']}}

end