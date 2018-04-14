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
#  note               :text(65535)
#  created_by_user_id :integer
#

class Booking < ActiveRecord::Base
  validates :booking_type_id, presence: true
  validates :booking_request_id, presence: true

  belongs_to :booking_type
  belongs_to :booking_request
  belongs_to :booking_status
  belongs_to :created_by_user, class_name: 'User'


  has_many :travel_members

  has_many :attachments, class_name: 'BookingAttachment'

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

  accepts_nested_attributes_for :travel_members
end
