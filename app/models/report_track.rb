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

  default_scope {order('created_at ASC')}

  def self.prior_users(user, report)
    tracking_for_report = where(report_id: report.id)
    return nil if tracking_for_report.blank?
    track = tracking_for_report.find_by(action_user_id: user.id)
    unless track.blank?
      tracking_for_report = tracking_for_report.where('created_at < ?', track.created_at)
    end
    user_ids = tracking_for_report.map(&:user_id).uniq
    if user_ids.size > 0
      return User.where(id: user_ids).where(company_id: user.company_id)
    end
    nil
  end
end
