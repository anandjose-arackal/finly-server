# == Schema Information
#
# Table name: analytics_dashboard_schedule_user_mappings
#
#  id                     :bigint           not null, primary key
#  company_id             :integer          not null
#  analytics_dashboard_id :integer          not null
#  user_id                :integer          not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class AnalyticsDashboardScheduleUserMapping < ApplicationRecord
  belongs_to :company
  belongs_to :analytics_dashboard
  belongs_to :user

  def as_json(options={})
    {
        id: id, user: user
    }
  end

end
