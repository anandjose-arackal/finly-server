# == Schema Information
#
# Table name: booking_trains
#
#  id                    :integer          not null, primary key
#  journey_source        :string(255)
#  journey_destination   :string(255)
#  journey_date          :date
#  departure_time        :string(255)
#  train_number          :string(255)
#  pnr                   :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  parent_id             :integer
#  parent_type           :string(255)
#  booking_class         :string(255)
#  boarding_station_name :string(255)
#  start_time            :text(65535)
#  end_time              :text(65535)
#

require 'test_helper'

class BookingTrainTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
