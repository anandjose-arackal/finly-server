class TaskManager::Workflows::Contracts::Event < TaskManager::Workflows::Contracts::Task

  property :event_key, validates: {presence: true}
  property :trigger_type, validates: {presence: true, inclusion: {in: ['event']}}

  validate :event_key_presence

  def event_key_presence
    master = Documents::Master.for(self.model_class)
    if master.blank?
      errors.add :base, 'Master is invalid'
      return
    end
    events = master.all_events
    unless events.include?(self.event_key.to_s.to_sym)
      errors.add :event_key, 'is not valid'
      return
    end
  end

end