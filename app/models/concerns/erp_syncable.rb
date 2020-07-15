module ErpSyncable
  extend ActiveSupport::Concern

  included do
    belongs_to :erp_sync_status
    has_many :erp_sync_attempts, as: :record
  end

end