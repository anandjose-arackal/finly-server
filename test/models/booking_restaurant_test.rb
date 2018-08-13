# == Schema Information
#
# Table name: booking_restaurants
#
#  id                      :integer          not null, primary key
#  reservation_destination :string(255)
#  reservation_date        :date
#  reservation_time        :string(255)
#  restaurant_name         :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_id               :integer
#  parent_type             :string(255)
#  restaurant_rating       :string(255)
#  start_time              :text(65535)
#  end_time                :text(65535)
#

require 'test_helper'

class BookingRestaurantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
