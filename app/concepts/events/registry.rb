class Events::Registry

  def self.add_event(klass, event, consumer_key)
    raise "Key #{consumer_key} is already taken" if find_by_consumer_key(consumer_key).present?

    events(event)[consumer_key] = klass
  end

  def self.add_scheduled_job(klass)
    scheduled_jobs << klass unless scheduled_jobs.include? klass
  end

  def self.events(event = NoObject)
    @events ||= {}.with_indifferent_access
    return @events if event == NoObject

    @events[event] ||= {}.with_indifferent_access
  end

  def self.find_by_consumer_key(consumer_key)
    events.each do |event, consumers|
      return consumers[consumer_key] if consumers[consumer_key].present?
    end

    nil
  end

  def self.async_events(event, consumer_key: NoObject)
    events(event).values.select do |klass|
      klass.async? and (consumer_key == NoObject or klass.consumer_key == consumer_key)
    end
  end

  def self.sync_events(event, consumer_key: NoObject)
    events(event).values.select do |klass|
      !klass.async? and (consumer_key == NoObject or klass.consumer_key == consumer_key)
    end
  end

  def self.scheduled_jobs
    @scheduled_jobs ||= []
  end

end