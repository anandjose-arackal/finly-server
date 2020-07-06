# == Schema Information
#
# Table name: macro_schedules
#
#  id               :bigint           not null, primary key
#  macro_id         :integer
#  every            :integer
#  hour             :integer
#  minute           :integer
#  day_of_the_week  :integer
#  day_of_the_month :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class MacroSchedule < FinlyMacrosRecord
  EVERY = {day: 1, week: 2, month: 3}.with_indifferent_access
  DAY_OF_THE_WEEK = {sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6}.with_indifferent_access

  belongs_to :schedulable, polymorphic: true

  def frequency
    case every
    when :day
      1.day
    when :week
      1.week
    when :month
      1.month
    end
  end
end
