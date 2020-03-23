class Events::Registry

  def self.add_event(klass, event)
    events(event) << klass
  end

  def self.events(event = NoObject)
    @events ||= {}.with_indifferent_access
    return @events if event == NoObject

    @events[event] ||= []
  end

  def self.async_events(event)
    events(event).select do |klass|
      klass.async?
    end
  end

  def self.sync_events(event)
    events(event).select do |klass|
      !klass.async?
    end
  end

end