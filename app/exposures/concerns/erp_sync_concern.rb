module Concerns::ErpSyncConcern
  extend ActiveSupport::Concern

  included do
    attribute :erp_sync_status, record_attribute: true, exposure: true, includes: [:erp_sync_status]
    attribute :erp_sync_message, record_attribute: true
    attribute :erp_sync_reference_id, record_attribute: true
    attribute :erp_sync_attempted_at, record_attribute: true
    attribute :erp_sync_attempts_count, record_attribute: true
  end

end