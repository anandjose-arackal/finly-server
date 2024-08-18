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
    cmp = nil
    if self.is_a?(Company)
      cmp = self
    elsif self.respond_to?(:company) and self.respond_to?(:company_id) and self.company.present? and self.company.is_a?(Company)
      cmp = self.company
    end
      # if previous_changes['created_at'].present?
      # New record
      #Events::Publisher::Record::Create(self, RequestStoreUtil.current_user, (RequestStoreUtil.current_company || cmp))
      #else
      # Old record
      # Events::Publisher::Record::Update(self, RequestStoreUtil.current_user, (RequestStoreUtil.current_company || cmp), previous_changes)
      #end
  end

  def before_destroy_callbacks
    cmp = nil
    if self.is_a?(Company)
      cmp = self
    elsif self.respond_to?(:company) and self.respond_to?(:company_id) and self.company.present? and self.company.is_a?(Company)
      cmp = self.company
    end
      #Events::Publisher::Record::Destroy(self, RequestStoreUtil.current_user, (RequestStoreUtil.current_company || cmp))
  end
end