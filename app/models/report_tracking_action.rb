# == Schema Information
#
# Table name: report_tracking_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#






class ReportTrackingAction < ApplicationRecord
  include Seedable

  def self.values
    [
        :create,
        :retract,
        :submit,
        :approve,
        :auto_approve,
        :reject,
        :unapprove,
        :take_control,
        :settled,
        :settlement_confirmed,
        :closed,
    ]
  end


end
