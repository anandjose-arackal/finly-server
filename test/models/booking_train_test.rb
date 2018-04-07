# == Schema Information
#
# Table name: booking_trains
#
#  id                  :integer          not null, primary key
#  journey_source      :string(255)
#  journey_destination :string(255)
#  journey_date        :date
#  departure_time      :string(255)
#  train_number        :string(255)
#  pnr                 :string(255)
#  booking_id          :integer
#  booking_request_id  :integer
#  booking_type_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class BookingTrainTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
