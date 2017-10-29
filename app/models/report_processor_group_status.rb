# == Schema Information
#
# Table name: report_processor_group_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportProcessorGroupStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:processing, :partially_completed, :completed, :failed, :cancelled]
  end

end
