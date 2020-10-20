module EventProducer
  extend ActiveSupport::Concern

  included do
    include DynamicAttributes
    setup_event_producers
  end

  module ClassMethods
    def event_channel(name = NoObject)
      @event_channel = name unless name == NoObject

      @event_channel || self.table_name
    end

    def setup_event_producers
      after_commit :after_save_callbacks
      before_destroy :before_destroy_callbacks
    end
  end

  def after_save_callbacks
    if previous_changes['created_at'].present?
      # New record
      Events::Publisher::Record::Create(self, RequestStoreUtil.current_user, RequestStoreUtil.current_company)
    else
      # Old record
      Events::Publisher::Record::Update(self, RequestStoreUtil.current_user, RequestStoreUtil.current_company, previous_changes)
    end
  end

  def before_destroy_callbacks
    Events::Publisher::Record::Destroy(self, RequestStoreUtil.current_user, RequestStoreUtil.current_company)
  end
end