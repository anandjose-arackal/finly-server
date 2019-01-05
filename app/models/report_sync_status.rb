# == Schema Information
#
# Table name: report_sync_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportSyncStatus < ApplicationRecord
  include Seedable

  def self.values
    [:not_synced, :in_progress, :synced, :partially_synced, :exported]
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
