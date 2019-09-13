# == Schema Information
#
# Table name: event_schedules
#
#  id               :bigint           not null, primary key
#  every            :integer
#  hour             :integer
#  minute           :integer
#  day_of_the_week  :integer
#  day_of_the_month :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TaskSchedule < ApplicationRecord
  EVERY = {day: 1, week: 2, month: 3}.with_indifferent_access
  DAY_OF_THE_WEEK = {sunday: 1, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6}.with_indifferent_access
end
