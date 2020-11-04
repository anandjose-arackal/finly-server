# Responsible for sending scheduled reports via email to the customer
class AnalyticsDashboards::Scheduler
  include Sidekiq::Worker

  def self.call
    completed_dashboards = []
    time = DateTime.now
    AnalyticsDashboardSchedule.scheduled_at(time).includes(:analytics_dashboard).find_each do |dashboard_schedule|
      next if dashboard_schedule.analytics_dashboard.reports.blank?

      # Prevent conflicting schedules to mail the same dashboard twice
      next if completed_dashboards.include?(dashboard_schedule.analytics_dashboard_id)
      completed_dashboards << dashboard_schedule.analytics_dashboard_id

      self.perform_async(dashboard_schedule.analytics_dashboard_id)
    end
  end

  attr_accessor :analytics_dashboard

  def perform(id, options={})
    self.analytics_dashboard = AnalyticsDashboard.find(id)
    reports = self.analytics_dashboard.reports
    reports.each do |report|
      report[:data] = build_data(report)
    end

  end

  def build_data(report)
    query = report.dig('vizState', 'query')
    result = CubeJs.load(token, query)
    if result.success?
      result.message
    end

    nil
  end

  def token
    @token ||= CubeJs.generate_token(analytics_dashboard.created_by, expiry: 30.minutes.from_now.to_i)
  end

end