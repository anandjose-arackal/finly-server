# == Schema Information
#
# Table name: booking_requests
#
#  id                            :integer          not null, primary key
#  booking_status_id             :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  travel_request_destination_id :integer
#  booking_type_id               :integer
#  note                          :text(65535)
#

class BookingRequest < ActiveRecord::Base

  # validates :travel_request_destination_id, presence: true

  belongs_to :booking_type
  belongs_to :booking_status
  belongs_to :travel_request_destination
  has_many :bookings
  has_many :travel_members

  has_one :booking_car_rental, as: :parent
  has_one :booking_bus, as: :parent
  has_one :booking_flight, as: :parent
  has_one :booking_hotel, as: :parent
  has_one :booking_restaurant, as: :parent
  has_one :booking_train, as: :parent
  has_one :booking_custom, as: :parent

  accepts_nested_attributes_for :booking_car_rental
  accepts_nested_attributes_for :booking_bus
  accepts_nested_attributes_for :booking_flight
  accepts_nested_attributes_for :booking_hotel
  accepts_nested_attributes_for :booking_restaurant
  accepts_nested_attributes_for :booking_train
  accepts_nested_attributes_for :booking_custom

  accepts_nested_attributes_for :travel_members

  delegate :flight?, :train?, :bus?, :car_rental?, :hotel?, :restaurant?, to: :booking_type

  validates :booking_type_id, presence: true
  validates :booking_status_id, presence: true
  validate :at_least_one_type

  private

  def at_least_one_type
    case self.booking_type_id
      when BookingType.id_for(:flight)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated flight booking")
        end
      when BookingType.id_for(:hotel)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated hotel booking")
        end
      when BookingType.id_for(:restaurant)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated restaurant booking")
        end
      when BookingType.id_for(:bus)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated bus booking")
        end
      when BookingType.id_for(:trail)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated trail booking")
        end
      when BookingType.id_for(:car_rental)
        if self.booking_car_rental.nil?
          errors.add(:booking_request, "needs to have an associated car rental booking")
        end
      when BookingType.id_for(:custom)
        if self.booking_flight.nil?
          errors.add(:booking_request, "needs to have an associated custom booking")
        end
      else
        errors.add(:expense, "type is invalid")
    end
  end
end
