module EventBus::Subscriber

  def self.included(base)
    base.extend ClassMethods
    base.include DynamicAttributes
    base.class_attr :bus
    base.class_attr :subscriptions, default: []
  end

  module ClassMethods

    # def subscriber_map
    #   EVENT_BUS_SUBSCRIBERS[self.name] = {bus: nil, subscriptions: []} if EVENT_BUS_SUBSCRIBERS[self.name].nil?
    #   EVENT_BUS_SUBSCRIBERS[self.name]
    # end

    # def bus(klass = NoObject)
    #   unless klass == NoObject
    #     subscriber_map[:bus] = klass
    #   end
    #   subscriber_map[:bus]
    # end

    # def subscriptions
    #   subscriber_map[:subscriptions]
    # end

    def subscribe(event)
      bus.subscribe(event, self)
      subscriptions << event
    end

  end

end