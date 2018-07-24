# == Schema Information
#
# Table name: booking_hotels
#
#  id                :integer          not null, primary key
#  hotel_name        :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_id         :integer
#  parent_type       :string(255)
#  location_id       :integer          not null
#  checkin_datetime  :datetime
#  checkout_datetime :datetime
#  description       :text(65535)
#  hotel_address     :text(65535)
#  cost_id           :integer
#  is_deleted        :boolean          default(FALSE)
#

require 'test_helper'

class BookingHotelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
