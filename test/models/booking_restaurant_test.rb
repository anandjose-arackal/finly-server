# == Schema Information
#
# Table name: booking_restaurants
#
#  id                   :integer          not null, primary key
#  restaurant_name      :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  parent_id            :integer
#  parent_type          :string(255)
#  location_id          :integer          not null
#  restaurant_address   :text(65535)
#  reservation_datetime :datetime
#  number_of_guests     :integer
#  description          :text(65535)
#  is_deleted           :boolean          default(FALSE)
#

require 'test_helper'

class BookingRestaurantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
