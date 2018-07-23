# == Schema Information
#
# Table name: booking_buses
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_id          :integer
#  parent_type        :string(255)
#  booking_class      :string(255)
#  from_id            :integer          not null
#  to_id              :integer          not null
#  departure_datetime :datetime         not null
#  arrival_datetime   :datetime
#  cost_id            :integer
#  boarding_point     :text(65535)
#  drop_point         :text(65535)
#  description        :text(65535)
#

require 'test_helper'

class BookingBusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
