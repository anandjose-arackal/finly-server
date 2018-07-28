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


  has_many :travel_members, dependent: :destroy

  has_many :attachments, class_name: 'BookingAttachment', dependent: :destroy

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


  delegate :flight?, :train?, :bus?, :car_rental?, :hotel?, :restaurant?, to: :booking_type

  accepts_nested_attributes_for :travel_members, allow_destroy: true

  validates :booking_status_id, presence: true
  validates :booking_type_id, presence: true
  validates :created_by_user_id, presence: true

  scope :booking_options, -> { where booking_status_id: BookingStatus.id_for(:booking_option) }
  scope :confirmed_bookings, -> { where.not booking_status_id: BookingStatus.id_for(:booking_option) }

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
        booking_other: booking_other
    }
  end

end
