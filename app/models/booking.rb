# == Schema Information
#
# Table name: bookings
#
#  id                 :integer          not null, primary key
#  booking_request_id :integer
#  booking_status_id  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Booking < ActiveRecord::Base
  belongs_to :booking_request
  belongs_to :booking_status

  has_one :booking_car_rental
  has_one :booking_bus
  has_one :booking_flight
  has_one :booking_hotel
  has_one :booking_restaurant
  has_one :booking_train
end
