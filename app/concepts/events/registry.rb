class Events::Registry

  def self.register_queue(klass, event, async: false, options: {})
    type = async ? :async : :sync
    registry(event)[:queue][type] << klass
  end

  def self.register_request(klass, event, async: false, options: {})
    type = async ? :async : :sync
    registry(event)[:request][type] << klass
  end

  def self.registry(event)
    return nil if event.nil?

    @registry ||= {}.with_indifferent_access
    @registry[event] ||= {queue: {async: [], sync: []}, request: {async: [], sync: []}, scheduled: []}.with_indifferent_access
  end

  def self.queue_listeners(event, type: :sync)
    raise "Invalid listener type #{type}" unless [:sync, :async].include? type
    registry(event)[:queue][type]
  end

  def self.request_handlers(event, type: :sync)
    raise "Invalid listener type #{type}" unless [:sync, :async].include? type
    registry(event)[:request][type]
  end

end