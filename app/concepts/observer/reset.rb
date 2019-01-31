class Observer::Reset

  def self.call
    OBSERVERS_MASTER.clear
    OBSERVERS.clear
  end

end