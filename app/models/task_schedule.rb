# == Schema Information
#
# Table name: task_schedules
#
#  id               :bigint           not null, primary key
#  every            :integer
#  hour             :integer
#  minute           :integer
#  day_of_the_week  :integer
#  day_of_the_month :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  schedulable_id   :string(255)
#  schedulable_type :string(255)
#

class TaskSchedule < ApplicationRecord
  EVERY = {day: 1, week: 2, month: 3}.with_indifferent_access
  DAY_OF_THE_WEEK = {sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6}.with_indifferent_access


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
