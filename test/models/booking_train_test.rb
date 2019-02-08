# == Schema Information
#
# Table name: booking_trains
#
#  id                  :integer          not null, primary key
#  train_number        :string(255)
#  pnr                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  parent_type         :string(255)
#  booking_class       :string(255)
#  from_id             :integer          not null
#  boarding_station    :string(255)
#  to_id               :integer          not null
#  destination_station :string(255)
#  description         :string(255)
#  seat_number         :string(255)
#  cost_id             :integer
#  is_deleted          :boolean          default(FALSE)
#  departure_date      :date
#  departure_time      :time
#  arrival_date        :date
#  arrival_time        :time
#  booking_id          :integer
#  deleted_at          :datetime
#

require 'test_helper'

class BookingTrainTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
