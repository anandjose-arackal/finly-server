class TaskManager::Master

  TRIGGERS = {
      event: {
          contract: TaskManager::Workflows::Contracts::Event
      },
      schedule: {
          contract: TaskManager::Workflows::Contracts::Schedule
      }
  }

  def self.contract_for(trigger, model)
    TRIGGERS&.dig(trigger&.to_s&.to_sym, :contract)&.new(model)
  end

  def self.valid_trigger?(type)
    TRIGGERS&.dig(type&.to_s&.to_sym).present?
  end

end