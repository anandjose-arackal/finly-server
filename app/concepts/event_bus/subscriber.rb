module EventBus::Subscriber

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def subscriber_map
      EVENT_BUS_SUBSCRIBERS[self.name] = {bus: nil, subscriptions: []} if EVENT_BUS_SUBSCRIBERS[self.name].nil?
      EVENT_BUS_SUBSCRIBERS[self.name]
    end

    def bus(klass = NoObject)
      unless klass == NoObject
        subscriber_map[:bus] = klass
      end
      subscriber_map[:bus]
    end

    def subscriptions
      subscriber_map[:subscriptions]
    end

    def subscribe(event, subscriber = self, options={})
      bus = options&.dig(:bus) || subscriber_map[:bus]
      raise "Bus has not been defined for #{self.name}" if bus.nil?

      bus.subscribe(event, subscriber)
      subscriber_map[:subscriptions] << event
    end

  end

end