module ActiveRecordMaster
  extend ActiveSupport::Concern

  included do
    include DynamicAttributes
    class_attr :policy
    class_attr :event_channel, default: self.name.underscore
    class_attr :record_events, default: []
    class_attr :collection_events, default: []
    class_attr :form
    class_attr :state_machine
  end

  module ClassMethods
    def resolver(key = :default, klass)
      resolvers[key] = klass
    end

    def resolvers
      @resolvers ||= {}
    end

    def record_event?(event)
      return false if event.blank?
      record_events.include?(event) or record_events.include?(event.gsub("#{event_channel}.", ""))
    end

    def collection_event?(event)
      return false if event.blank?
      collection_events.include?(event) or collection_events.include?(event.gsub("#{event_channel}.", ""))
    end

    def all_events
      record_events + collection_events
    end

    def resolve(user, scope: :default, params: {}, filter: false, paginate: false, includes: [])
      collection = resolvers[scope]&.new(user, self)&.resolve(params: params, filter: filter, paginate: paginate, includes: includes)
      collection
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