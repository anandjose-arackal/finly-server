class EventManager::Triggers::Event::Contract < EventManager::Workflow::Contract

  property :request_key, validates: {presence: true}
  property :trigger_type, validates: {presence: true, inclusion: {in: ['event']}}

end