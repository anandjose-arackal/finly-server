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
