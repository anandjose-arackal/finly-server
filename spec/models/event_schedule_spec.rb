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

require 'rails_helper'

# RSpec.describe EventSchedule, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
# end
