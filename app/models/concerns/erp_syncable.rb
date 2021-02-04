module ErpSyncable
  extend ActiveSupport::Concern

  included do

    scope :with_erp_sync_status_pending, -> {
      pending_ids = ErpSyncStatus.ids_for(:pending)
      pending_ids << nil
      where erp_sync_status_id: pending_ids
    }

    # Define pending_erp_sync in the model
    scope :pending_erp_sync_or_modified, -> (*args) {
      synced_id = ErpSyncStatus.ids_for(:synced)
      pending_docs = pending_erp_sync
      updated_docs = where('erp_sync_attempted_at < updated_at AND erp_sync_status_id = ?',  synced_id)
      pending_docs.or(updated_docs)
    }


    belongs_to :erp_sync_status, optional: true
    has_many :erp_sync_attempts, as: :record

    ransack_scopes :pending_erp_sync
    ransack_scopes :pending_erp_sync_or_modified
  end

end