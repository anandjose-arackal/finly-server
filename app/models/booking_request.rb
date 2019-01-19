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
#  is_deleted                    :boolean          default(FALSE)
#  travel_request_id             :integer          not null
#  deleted_at                    :datetime
#

class BookingRequest < ActiveRecord::Base
  include SoftDeletable

  belongs_to :booking_type
  belongs_to :booking_status
  belongs_to :travel_request_destination
  belongs_to :travel_request
  has_many :bookings, dependent: :destroy
  has_many :travel_members, dependent: :destroy

  has_one :booking_car_rental, as: :parent, dependent: :destroy
  has_one :booking_bus, as: :parent, dependent: :destroy
  has_one :booking_flight, as: :parent, dependent: :destroy
  has_one :booking_hotel, as: :parent, dependent: :destroy
  has_one :booking_restaurant, as: :parent, dependent: :destroy
  has_one :booking_train, as: :parent, dependent: :destroy
  has_one :booking_other, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :booking_car_rental, allow_destroy: true
  accepts_nested_attributes_for :booking_bus, allow_destroy: true
  accepts_nested_attributes_for :booking_flight, allow_destroy: true
  accepts_nested_attributes_for :booking_hotel, allow_destroy: true
  accepts_nested_attributes_for :booking_restaurant, allow_destroy: true
  accepts_nested_attributes_for :booking_train, allow_destroy: true
  accepts_nested_attributes_for :booking_other, allow_destroy: true

  accepts_nested_attributes_for :travel_members, allow_destroy: true

  scope :sort_by_type, -> { order booking_type_id: :asc }
  scope :group_by_type, -> { group :booking_type_id }

  delegate :flight?, :train?, :bus?, :car_rental?, :hotel?, :restaurant?, to: :booking_type

  # validates :booking_type_id, presence: true
  # validates :booking_status_id, presence: true
  # validates :travel_request_destination_id, presence: true
  validate :at_least_one_type

  scope :with_id, ->(id) {where id: id}

  def as_json(options = {})
    {
        id: id,
        booking_type: booking_type,
        note: note,
        booking_status: booking_status,
        travel_members: travel_members,
        booking_car_rental: booking_car_rental,
        booking_bus: booking_bus,
        booking_flight: booking_flight,
        booking_hotel: booking_hotel,
        booking_restaurant: booking_restaurant,
        booking_train: booking_train,
        booking_other: booking_other,
        bookings_options: bookings.booking_options,
        bookings: bookings.confirmed_bookings
    }
  end

  private

  def at_least_one_type
    case self.booking_type_id
    when BookingType.id_for(:flight)
      if self.booking_flight.nil?
        errors.add(:booking_request, "needs to have an associated flight booking")
      end
    when BookingType.id_for(:hotel)
      if self.booking_hotel.nil?
        errors.add(:booking_request, "needs to have an associated hotel booking")
      end
    when BookingType.id_for(:restaurant)
      if self.booking_restaurant.nil?
        errors.add(:booking_request, "needs to have an associated restaurant booking")
      end
    when BookingType.id_for(:bus)
      if self.booking_bus.nil?
        errors.add(:booking_request, "needs to have an associated bus booking")
      end
    when BookingType.id_for(:train)
      if self.booking_train.nil?
        errors.add(:booking_request, "needs to have an associated trail booking")
      end
    when BookingType.id_for(:car_rental)
      if self.booking_car_rental.nil?
        errors.add(:booking_request, "needs to have an associated car rental booking")
      end
    when BookingType.id_for(:custom)
      if self.booking_other.nil?
        errors.add(:booking_request, "needs to have an associated custom booking")
      end
    else
      errors.add(:expense, "type is invalid")
    end
  end
end
