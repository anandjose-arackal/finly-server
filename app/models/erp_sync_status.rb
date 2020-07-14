class ErpSyncStatus < ApplicationRecord
  include Seedable

  def self.values
    [:pending, :in_progress, :synced, :failed]
  end

end
