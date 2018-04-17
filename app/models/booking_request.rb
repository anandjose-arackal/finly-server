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
  validates :booking_type_id, presence: true

  # validates :travel_request_destination_id, presence: true

  belongs_to :booking_type
  belongs_to :booking_status
  belongs_to :travel_request_destination
  has_many :bookings, dependent: :destroy
  has_many :travel_members, dependent: :destroy

  has_one :booking_car_rental, as: :parent, dependent: :destroy
  has_one :booking_bus, as: :parent, dependent: :destroy
  has_one :booking_flight, as: :parent, dependent: :destroy
  has_one :booking_hotel, as: :parent, dependent: :destroy
  has_one :booking_restaurant, as: :parent, dependent: :destroy
  has_one :booking_train, as: :parent, dependent: :destroy
  has_one :booking_custom, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :booking_car_rental, allow_destroy: true
  accepts_nested_attributes_for :booking_bus, allow_destroy: true
  accepts_nested_attributes_for :booking_flight, allow_destroy: true
  accepts_nested_attributes_for :booking_hotel, allow_destroy: true
  accepts_nested_attributes_for :booking_restaurant, allow_destroy: true
  accepts_nested_attributes_for :booking_train, allow_destroy: true
  accepts_nested_attributes_for :booking_custom, allow_destroy: true

  accepts_nested_attributes_for :travel_members, allow_destroy: true

  delegate :flight?, :train?, :bus?, :car_rental?, :hotel?, :restaurant?, to: :booking_type
end
