module EventBus::Bus

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def event_bus_master
      if EVENT_BUS_MASTER[self.name].nil?
        EVENT_BUS_MASTER[self.name] = {subscribers: {}.with_indifferent_access, subscribers_path: nil}
      end
      EVENT_BUS_MASTER[self.name]
    end

    def subscribers_path(path = NoObject)
      unless path == NoObject
        event_bus_master[:subscribers_path] = path
      end
      event_bus_master[:subscribers_path]
    end

    def subscribe(event, subscriber)
      subscribers = event_bus_master[:subscribers]
      subscribers[event] = [] if subscribers[event].nil?
      subscribers[event] << subscriber unless subscribers[event].include?(subscriber)
    end

    def subscribers(event=nil)
      subscribers = event_bus_master[:subscribers]
      if subscribers.blank? and not Rails.env.production? and self.subscribers_path.present?
        Dir.glob("#{subscribers_path}/**/*.rb").each {|r| load r}
      end
      if event.present?
        return subscribers[event]
      end
      subscribers
    end

  end

end