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
#  travel_request_id  :integer          not null
#  destination_id     :integer          not null
#  parent_booking_id  :integer
#  reject_reason      :text(65535)
#

class Booking < ApplicationRecord

  belongs_to :booking_type, optional: true
  belongs_to :booking_status, optional: true
  # belongs_to :booking_request, optional: true
  belongs_to :destination, optional: true, class_name: 'TravelRequestDestination'
  belongs_to :travel_request, optional: true
  belongs_to :travel_request_comment, optional: true
  belongs_to :created_by_user, optional: true, class_name: 'User'

  has_many :bookings, foreign_key: :parent_booking_id, dependent: :destroy
  belongs_to :parent_booking, optional: true, class_name: 'Booking'

  has_many :custom_fields, as: :parent, dependent: :destroy

  has_many :travel_members, dependent: :destroy

  has_many :attachments, class_name: 'BookingAttachment', dependent: :destroy

  has_one :booking_car_rental, dependent: :destroy, inverse_of: :booking
  has_one :booking_bus, dependent: :destroy, inverse_of: :booking
  has_one :booking_flight, dependent: :destroy, inverse_of: :booking
  has_one :booking_hotel, dependent: :destroy, inverse_of: :booking
  has_one :booking_restaurant, dependent: :destroy, inverse_of: :booking
  has_one :booking_train, dependent: :destroy, inverse_of: :booking
  has_one :booking_other, dependent: :destroy, inverse_of: :booking

  accepts_nested_attributes_for :booking_car_rental, allow_destroy: true
  accepts_nested_attributes_for :booking_bus, allow_destroy: true
  accepts_nested_attributes_for :booking_flight, allow_destroy: true
  accepts_nested_attributes_for :booking_hotel, allow_destroy: true
  accepts_nested_attributes_for :booking_restaurant, allow_destroy: true
  accepts_nested_attributes_for :booking_train, allow_destroy: true
  accepts_nested_attributes_for :booking_other, allow_destroy: true
  accepts_nested_attributes_for :travel_members, allow_destroy: true
  accepts_nested_attributes_for :custom_fields, allow_destroy: true

  delegate :flight?, :train?, :bus?, :car_rental?, :hotel?, :restaurant?, to: :booking_type
  delegate :request?, :option?, :confirmed?, :processing?, :selected_for_booking?, :cancelled?, :rejected?, to: :booking_status

  accepts_nested_attributes_for :travel_members, allow_destroy: true

  validates :booking_type_id, presence: true
  validates :booking_status_id, presence: true
  validates :booking_type_id, presence: true
  validates :created_by_user_id, presence: true
  validates :travel_request_id, presence: true
  # validates :booking_request_id, presence: true
  validate :at_least_one_type
  validate :booking_date_range

  scope :with_id, ->(id) {where id: id}
  scope :sort_by_type, -> {order booking_type_id: :asc}
  scope :group_by_type, -> {group :booking_type_id}
  scope :requests, -> {where booking_status_id: BookingStatus.ids_for(:request)}
  scope :options, -> {where booking_status_id: BookingStatus.id_for(:option)}
  scope :rejected, -> {where booking_status_id: BookingStatus.id_for(:rejected)}
  scope :processing, -> {where booking_status_id: BookingStatus.id_for(:processing)}
  scope :confirmed, -> {where booking_status_id: BookingStatus.id_for(:confirmed)}
  scope :cancelled, -> {where booking_status_id: BookingStatus.id_for(:cancelled)}
  scope :selected_for_booking, -> {where booking_status_id: BookingStatus.id_for(:selected_for_booking)}
  scope :without_parent, -> {where parent_booking_id: nil}
  scope :with_travel_request_id, -> (id) {where travel_request_id: id}

  def booking_type_object
    case booking_type_id
    when BookingType.id_for(:flight)
      return booking_flight
    when BookingType.id_for(:bus)
      return booking_bus
    when BookingType.id_for(:train)
      return booking_train
    when BookingType.id_for(:car_rental)
      return booking_car_rental
    when BookingType.id_for(:hotel)
      return booking_hotel
    when BookingType.id_for(:restaurant)
      return booking_restaurant
    when BookingType.id_for(:others)
      return booking_other
    end
  end

  def as_json(options = {})
    data = {
        id: id,
        booking_type: booking_type,
        note: note,
        booking_status: booking_status,
        travel_members: travel_members,
    }
    data[booking_type&.name] = booking_type_object
    if self.request? or self.confirmed? or self.rejected?
      data[:options] = self.bookings.options
      data[:selected_for_booking] = self.bookings.selected_for_booking
      data[:confirmed] = self.bookings.confirmed&.first
      data[:cancelled] = self.bookings.cancelled
      data[:custom_fields] = self.custom_fields
    end
    if self.rejected?
      data[:reject_reason] = self.reject_reason
    end
    if self.confirmed?
      data[:attachments] = self.attachments
    end
    # Jugaad
    if parent_booking_id.blank? and not options&.dig(:skip_confirmed)
      if confirmed?
        data[:confirmed] = self.as_json(skip_confirmed: true)
      elsif cancelled?
        data[:cancelled] = [self.as_json(skip_confirmed: true)]
      end
    end
    data
  end

  private

  def booking_date_range
    return unless request?
    return unless booking_type_object.valid?
    unless booking_type_object.valid_date_range(travel_request)
      errors.add :booking, 'dates cannot be outside the travel dates'
    end
  end


  def at_least_one_type
    case self.booking_type_id
    when BookingType.id_for(:flight)
      if self.booking_flight.nil?
        errors.add(:booking, "needs to have an associated flight booking")
      end
    when BookingType.id_for(:hotel)
      if self.booking_hotel.nil?
        errors.add(:booking, "needs to have an associated hotel booking")
      end
    when BookingType.id_for(:restaurant)
      if self.booking_restaurant.nil?
        errors.add(:booking, "needs to have an associated restaurant booking")
      end
    when BookingType.id_for(:bus)
      if self.booking_bus.nil?
        errors.add(:booking, "needs to have an associated bus booking")
      end
    when BookingType.id_for(:train)
      if self.booking_train.nil?
        errors.add(:booking, "needs to have an associated trail booking")
      end
    when BookingType.id_for(:car_rental)
      if self.booking_car_rental.nil?
        errors.add(:booking, "needs to have an associated car rental booking")
      end
    when BookingType.id_for(:custom)
      if self.booking_other.nil?
        errors.add(:booking, "needs to have an associated custom booking")
      end
    else
      errors.add(:booking, "type is invalid")
    end
  end

end
