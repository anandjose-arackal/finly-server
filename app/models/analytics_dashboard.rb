class AnalyticsDashboard < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :system_dashboard, optional: true

  has_many :schedules, class_name: 'AnalyticsDashboardSchedule'
  has_many :schedule_user_mappings, class_name: 'AnalyticsDashboardScheduleUserMapping'

  serialize :reports, JSON

  default_scope {order(name: :asc)}

  def as_json(options={})
    {
        id: id,
        name: name,
        description: description,
        default: !!default,
        reports: reports,
        schedules: schedules,
        schedule_user_mappings: schedule_user_mappings
    }
  end

end
