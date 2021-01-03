# == Schema Information
#
# Table name: analytics_dashboards
#
#  id                    :bigint           not null, primary key
#  app                   :string(255)      not null
#  company_id            :integer          not null
#  created_by_id         :integer          not null
#  name                  :string(255)      not null
#  description           :text(65535)
#  default               :boolean          default(FALSE)
#  reports               :text(65535)
#  is_system_dashboard   :boolean
#  system_dashboard_id   :string(255)
#  feature_subscriptions :text(65535)
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AnalyticsDashboard < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :system_dashboard, optional: true

  has_many :schedules, class_name: 'AnalyticsDashboardSchedule'
  has_many :schedule_user_mappings, class_name: 'AnalyticsDashboardScheduleUserMapping'

  validates_uniqueness_of :name, scope: [:created_by_id], conditions: -> { where(deleted_at: nil, is_system_dashboard: [false, nil]) }
  validates_presence_of :name

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
