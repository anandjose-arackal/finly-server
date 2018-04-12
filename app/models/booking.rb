# == Schema Information
#
# Table name: bookings
#
#  id                 :integer          not null, primary key
#  booking_request_id :integer
#  booking_status_id  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_type_id    :integer
#

class Booking < ActiveRecord::Base
  validates :booking_type_id, presence: true
  belongs_to :booking_request
  belongs_to :booking_status
  has_many :travel_members

  has_one :booking_car_rental, as: :parent
  has_one :booking_bus, as: :parent
  has_one :booking_flight, as: :parent
  has_one :booking_hotel, as: :parent
  has_one :booking_restaurant, as: :parent
  has_one :booking_train, as: :parent
end
