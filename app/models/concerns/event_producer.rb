module EventProducer
  extend ActiveSupport::Concern

  included do
    include DynamicAttributes
    class_attr :record_events, default: []
    class_attr :collection_events, default: []

    setup_event_producers
  end

  module ClassMethods
    def event_channel(name = NoObject)
      @event_channel = name unless name == NoObject

      @event_channel || self.table_name
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

    def setup_event_producers
      after_save :after_save_callbacks
      before_destroy :before_destroy_callbacks
    end
  end

  def after_save_callbacks
    if previous_changes['created_at'].present?
      # New record
      Events::Publisher::Record::Create(self, RequestStoreUtil.current_user)
    else
      # Old record
      Events::Publisher::Record::Update(self, RequestStoreUtil.current_user, previous_changes)
    end
  end

  def before_destroy_callbacks
    Events::Publisher::Record::Destroy(self, RequestStoreUtil.current_user)
  end
end