class EventManager::Config

  MODELS = %w(Invoice)
  TRIGGERS = {
      event: {
          contract: EventManager::Triggers::Event::Contract
      }
  }

  def models
    MODELS
  end

  def self.contract_for(trigger, model)
    TRIGGERS&.dig(trigger&.to_s&.to_sym, :contract)&.new(model)
  end

  def self.valid_trigger?(type)
    TRIGGERS&.dig(type&.to_s&.to_sym).present?
  end

end