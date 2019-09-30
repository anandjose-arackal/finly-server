class Events::Registry

  def self.register(klass, event, async, options = {})
    type = async ? :async : :sync
    registry(event)[type] << klass
  end

  def self.registry(event)
    return nil if event.nil?

    @registry ||= {}
    @registry[event] ||= {async: [], sync: []}
  end

  def self.listeners_for(event, type: :sync)
    raise "Invalid listener type #{type}" unless [:sync, :async].include? type
    registry(event)[type]
  end

end