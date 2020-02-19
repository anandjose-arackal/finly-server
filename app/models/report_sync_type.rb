# == Schema Information
#
# Table name: report_sync_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class ReportSyncType < ApplicationRecord
  include Seedable

  def self.values
    [:quickbooks, :tally_export]
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
