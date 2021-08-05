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
      synced_ids = ErpSyncStatus.ids_for(:synced, :failed)
      pending_docs = pending_erp_sync
      updated_docs = where('erp_sync_attempted_at < updated_at AND erp_sync_status_id IN (?)', synced_ids)
      pending_docs.or(updated_docs)
    }

    scope :with_erp_sync_status_ids, -> (status_ids) {
      where(erp_sync_status_id: status_ids)
    }

    scope :except_erp_sync_status_id, -> (status_ids) {
      where.not(erp_sync_status_id: status_ids)
    }

    belongs_to :erp_sync_status, optional: true
    has_many :erp_sync_attempts, as: :record

    ransack_scopes :pending_erp_sync
    ransack_scopes :pending_erp_sync_or_modified
    ransack_scopes :with_erp_sync_status_ids
    ransack_scopes :except_erp_sync_status_id
  end

end