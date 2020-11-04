# Responsible for sending scheduled reports via email to the customer
class AnalyticsDashboard::Scheduler
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

  def perform(id, options = {})
    self.analytics_dashboard = AnalyticsDashboard.find(id)
    reports = self.analytics_dashboard.reports
    reports.each do |report|
      data = build_data(analytics_dashboard.created_by, report)
      report[:data] = data['data'] if data.present?
    end

    reports
  end

  def build_data(user, report)
    query = report.dig('vizState', 'query')
    attempt = 0
    loop do
      CubeJs::Load.(params: {q: query}, current_user: user) do |m|
        m.success do |result|
          return result
        end

        m.failure do |result|
          return nil
        end

        m.wait do |result|
          attempt += 1
          if attempt > 3
            return nil
          else
            # Sleep for 15 seconds and check again
            sleep 15
          end
        end
      end
    end
  end
end