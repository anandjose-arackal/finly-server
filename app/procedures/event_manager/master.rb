class EventManager::Master

  TRIGGERS = {
      event: {
          contract: EventManager::Triggers::Event::Contract
      },
      schedule: {
          contract: EventManager::Triggers::Schedule::Contract
      }
  }

  def self.contract_for(trigger, model)
    TRIGGERS&.dig(trigger&.to_s&.to_sym, :contract)&.new(model)
  end

  def self.valid_trigger?(type)
    TRIGGERS&.dig(type&.to_s&.to_sym).present?
  end

end