class AnalyticsDashboardSchedule < ApplicationRecord
  FREQUENCY = %w(
      monthly weekly daily hourly last_day_of_month
  )

  DAY_OF_THE_WEEK = {
      sunday: "0", monday: "1", tuesday: "2", wednesday: "3", thursday: "4", friday: "5", saturday: "6"
  }.with_indifferent_access

  belongs_to :company
  belongs_to :analytics_dashboard

  scope :scheduled_at, -> (datetime) {
    hour = datetime.hour
    actual_minute = datetime.minute
    minute = actual_minute - actual_minute % 5 # Round to the previous multiple of 5
    day_of_the_month = datetime.day
    day_of_the_week = datetime.wday

    records = where(frequency: FREQUENCY_MONTHLY, day_of_the_month: day_of_the_month, hour: hour, minute: minute)
    records = records.or(where(frequency: FREQUENCY_WEEKLY, day_of_the_week: day_of_the_week, hour: hour, minute: minute))
    records = records.or(where(frequency: FREQUENCY_DAILY, hour: hour, minute: minute))
    records = records.or(where(frequency: FREQUENCY_HOURLY, minute: minute))
    # Todo last day of month
    records
  }

  def as_json(options = {})
    {
        id: id,
        frequency: frequency,
        hour: hour,
        minute: minute,
        day_of_the_week: day_of_the_week,
        day_of_the_month: day_of_the_month
    }
  end
end
