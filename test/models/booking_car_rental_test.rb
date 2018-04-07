# == Schema Information
#
# Table name: booking_car_rentals
#
#  id                     :integer          not null, primary key
#  journey_source         :string(255)
#  journey_destination    :string(255)
#  pickup_address         :text(65535)
#  journey_date           :date
#  pickup_time            :string(255)
#  reservation_start_date :date
#  reservation_end_date   :date
#  car_type               :string(255)
#  car_number             :string(255)
#  booking_id             :integer
#  booking_request_id     :integer
#  booking_type_id        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class BookingCarRentalTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
