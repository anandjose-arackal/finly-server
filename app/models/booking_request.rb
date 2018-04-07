# == Schema Information
#
# Table name: booking_requests
#
#  id                :integer          not null, primary key
#  booking_status_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class BookingRequest < ActiveRecord::Base
  belongs_to :booking_status
  has_many :bookings

  has_one :booking_car_rental
  has_one :booking_bus
  has_one :booking_flight
  has_one :booking_hotel
  has_one :booking_restaurant
  has_one :booking_train
end
