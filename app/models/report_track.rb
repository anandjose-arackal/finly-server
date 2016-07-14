# == Schema Information
#
# Table name: report_tracks
#
#  id                        :integer          not null, primary key
#  report_id                 :integer          not null
#  action_user_id            :integer
#  report_tracking_action_id :integer
#  report_status_id          :integer          not null
#  memo                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ReportTrack < ActiveRecord::Base
  belongs_to :report
  belongs_to :report_status
  belongs_to :tracking_action, class_name: 'ReportTrackingAction'
  belongs_to :action_user, class_name: 'User'

  default_scope { order('created_at ASC') }

  scope :created_before, ->(time) { where 'created_at < ?', time }
  scope :without_take_control_action, -> { where.not report_tracking_action_id: ReportTrackingAction.take_control_id }

end
