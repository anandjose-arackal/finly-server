# == Schema Information
#
# Table name: macro_schedules
#
#  id               :bigint           not null, primary key
#  macro_id         :integer
#  start_date       :datetime
#  end_date         :datetime
#  hour             :integer
#  minute           :integer
#  day_of_the_week  :integer
#  day_of_the_month :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  frequency        :string(255)      not null
#

class MacroSchedule < FinlyMacrosRecord
  # FREQUENCY = {
  #     monthly: 1, weekly: 2, daily: 3, hourly: 4, last_day_of_month: 5
  # }.with_indifferent_access

  FREQUENCY = %w(
      monthly weekly daily hourly last_day_of_month
  )

  DAY_OF_THE_WEEK = {
      sunday: "0", monday: "1", tuesday: "2", wednesday: "3", thursday: "4", friday: "5", saturday: "6"
  }.with_indifferent_access

  # DAY_OF_THE_WEEK = {
  #     sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6
  # }.with_indifferent_access

  belongs_to :company
  belongs_to :macro

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
