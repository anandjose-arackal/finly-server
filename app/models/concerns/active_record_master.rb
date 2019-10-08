module ActiveRecordMaster

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def resolver(key = :default, klass)
      resolvers[key] = klass
    end

    def resolvers
      @resolvers ||= {}
    end

    def policy(policy = NoObject)
      @policy = policy unless policy == NoObject
      @policy
    end

    def event_channel(event_channel = NoObject)
      @event_channel = event_channel unless event_channel == NoObject
      @event_channel || self.class.name.underscore
    end

    def record_events(*record_events)
      @record_events = record_events if record_events.present?
      @record_events ||= []
    end

    def record_event?(event)
      return false if event.blank?
      record_events.include?(event) or record_events.include?(event.gsub("#{event_channel}.", ""))
    end

    def collection_event?(event)
      return false if event.blank?
      collection_events.include?(event) or collection_events.include?(event.gsub("#{event_channel}.", ""))
    end

    def collection_events(*collection_events)
      @collection_events = collection_events if collection_events.present?
      @collection_events ||= []
    end

    def all_events
      @record_events + @collection_events
    end

    def form(form = NoObject)
      @form = form unless form == NoObject
      @form
    end

    def state_machine(state_machine = NoObject)
      @state_machine = state_machine unless state_machine == NoObject
      @state_machine
    end

    def create(create = NoObject)
      @create = create unless create == NoObject
      @create
    end

    def update(update = NoObject)
      @update = update unless update == NoObject
      @update
    end

    def resolve(user, scope: :default, filters: {})
      resolvers[scope]&.new(user, self)&.resolve(filters)
    end

    def representers
      @representers ||= {}
    end

    def representer(scope = :default, klass)
      @representers[scope] = klass
    end
  end

  def render(representer_scope = :default, representer: nil)
    renderer = representer || self.class.representers[representer_scope]
    if renderer.blank?
      raise "Renderer #{representer_scope} is not defined for #{self.name}"
    end
    renderer.new(self).to_json
  end
end