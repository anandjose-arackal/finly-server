# == Schema Information
#
# Table name: booking_hotels
#
#  id               :integer          not null, primary key
#  hotel_name       :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :integer
#  parent_type      :string(255)
#  location_id      :integer          not null
#  description      :text(65535)
#  hotel_address    :text(65535)
#  number_of_guests :integer
#  cost_id          :integer
#  is_deleted       :boolean          default(FALSE)
#  checkin_date     :date
#  checkin_time     :time
#  checkout_date    :date
#  checkout_time    :time
#  booking_id       :integer
#

require 'test_helper'

class BookingHotelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
