module ErpSyncable
  extend ActiveSupport::Concern

  included do
    scope :pending_erp_sync, -> (value) {
      pending_ids = ErpSyncStatus.ids_for(:pending, :failed)
      if value
        where erp_sync_status_id: pending_ids
      else
        where.not erp_sync_status_id: pending_ids
      end
    }

    belongs_to :erp_sync_status
    has_many :erp_sync_attempts, as: :record
  end

end