module ErpSyncable
  extend ActiveSupport::Concern

  included do
    scope :pending_erp_sync, -> (value) {
      pending_ids = ErpSyncStatus.ids_for(:pending, :failed)
      pending_ids << nil
      if value.to_s == '1'
        where erp_sync_status_id: pending_ids
      else
        where.not erp_sync_status_id: pending_ids
      end
    }

    belongs_to :erp_sync_status, optional: true
    has_many :erp_sync_attempts, as: :record

    ransack_scopes :pending_erp_sync
  end

end