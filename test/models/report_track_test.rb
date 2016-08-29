# == Schema Information
#
# Table name: report_tracks
#
#  id                        :integer          not null, primary key
#  report_id                 :integer          not null
#  action_user_id            :integer
#  report_tracking_action_id :integer
#  report_status_id          :integer          not null
#  user_report_role_id       :integer
#  memo                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  payment_id                :integer
#

require 'test_helper'

class ReportTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
