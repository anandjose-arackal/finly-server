# == Schema Information
#
# Table name: booking_hotels
#
#  id                      :integer          not null, primary key
#  reservation_destination :string(255)
#  reservation_start_date  :date
#  reservation_time        :string(255)
#  reservation_end_date    :date
#  hotel_name              :string(255)
#  booking_id              :integer
#  booking_request_id      :integer
#  booking_type_id         :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class BookingHotelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
