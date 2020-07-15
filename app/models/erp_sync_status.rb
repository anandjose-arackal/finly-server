# == Schema Information
#
# Table name: erp_sync_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ErpSyncStatus < ApplicationRecord
  include Seedable

  def self.values
    [:pending, :in_progress, :synced, :failed]
  end

end
