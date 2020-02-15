# == Schema Information
#
# Table name: export_job_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class ExportJobStatus < ApplicationRecord
  include Seedable

  def self.values
    [:pending, :in_progress, :completed, :failed]
  end

end
