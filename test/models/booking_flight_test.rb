# == Schema Information
#
# Table name: booking_flights
#
#  id               :integer          not null, primary key
#  pnr              :string(255)
#  airline          :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :integer
#  parent_type      :string(255)
#  stops            :string(255)
#  ticket_number    :string(255)
#  from_id          :integer          not null
#  to_id            :integer          not null
#  description      :text(65535)
#  terminal         :string(255)
#  cost_id          :integer
#  booking_class_id :integer
#  is_deleted       :boolean          default(FALSE)
#  departure_date   :date
#  departure_time   :time
#  arrival_date     :date
#  arrival_time     :time
#  booking_id       :integer
#

require 'test_helper'

class BookingFlightTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
