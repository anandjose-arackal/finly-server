module EventBus::Subscriber

  def self.included(base)
    base.extend ClassMethods
    base.include DynamicAttributes
    base.class_attr :bus
    base.class_attr :event
    base.class_attr :subscriptions, default: []
  end

  module ClassMethods
    def subscribe(event)
      event(event)
      bus.subscribe(event, self)
      subscriptions << event
    end

  end

end