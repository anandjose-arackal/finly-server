# == Schema Information
#
# Table name: booking_requests
#
#  id                            :integer          not null, primary key
#  booking_status_id             :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  travel_request_destination_id :integer
#

class BookingRequest < ActiveRecord::Base
  belongs_to :booking_status
  has_many :bookings
  has_many :travel_members

  has_one :booking_car_rental
  has_one :booking_bus
  has_one :booking_flight
  has_one :booking_hotel
  has_one :booking_restaurant
  has_one :booking_train

  accepts_nested_attributes_for :booking_car_rental
  accepts_nested_attributes_for :booking_bus
  accepts_nested_attributes_for :booking_flight
  accepts_nested_attributes_for :booking_hotel
  accepts_nested_attributes_for :booking_restaurant
  accepts_nested_attributes_for :booking_train
  accepts_nested_attributes_for :travel_members
end
