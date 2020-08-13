module ErpSyncable
  extend ActiveSupport::Concern

  included do

    scope :with_erp_sync_status_pending, -> {
      pending_ids = ErpSyncStatus.ids_for(:pending)
      pending_ids << nil
      where erp_sync_status_id: pending_ids
    }

    # Define pending_erp_sync in the model

    belongs_to :erp_sync_status, optional: true
    has_many :erp_sync_attempts, as: :record

    ransack_scopes :pending_erp_sync
  end

end