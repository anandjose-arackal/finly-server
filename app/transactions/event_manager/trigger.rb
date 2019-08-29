class EventManager::Trigger

  def self.event(type, params)
    unless EventManager::Config.valid_trigger?(type)
      # Todo handle error
      return
    end
  end

end