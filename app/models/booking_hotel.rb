# == Schema Information
#
# Table name: booking_hotels
#
#  id               :integer          not null, primary key
#  hotel_name       :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :integer
#  parent_type      :string(255)
#  location_id      :integer          not null
#  description      :text(65535)
#  hotel_address    :text(65535)
#  number_of_guests :integer
#  cost_id          :integer
#  is_deleted       :boolean          default(FALSE)
#  checkin_date     :date
#  checkin_time     :time
#  checkout_date    :date
#  checkout_time    :time
#  booking_id       :integer
#

class BookingHotel < ActiveRecord::Base
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation

  # belongs_to :parent, polymorphic: true
  belongs_to :booking, inverse_of: :booking_hotel
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :location, dependent: :destroy

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :cost

  # As front end calls this comment and not description, have to give an alias for validation purpose
  alias_attribute :comment, :description

  delegate :request?, to: :booking

  field_customization_key :booking_hotel
  customizable_validate :comment, presence: false, scope: [:booking, :travel_request, :company], if: :request?
  # validates :comment, presence: true

  validates :location, presence: true
  validates :checkin_date, presence: true
  validates :checkout_date, presence: true
  validate :acceptable_dates?

  scope :with_parent_booking_id, ->(id) { where parent_type: 'Booking', parent_id: id }
  scope :sum_cost, -> { joins(:cost).sum(:value) }

  def as_json(options = {})
    {
        id: id,
        hotel_name: hotel_name,
        location: location,
        checkin_date: DateUtils.date_formatted(checkin_date),
        checkin_time: DateUtils.time_formatted(checkin_time, military_time: true),
        checkout_date: DateUtils.date_formatted(checkout_date),
        checkout_time: DateUtils.time_formatted(checkout_time, military_time: true),
        description: description,
        hotel_address: hotel_address,
        number_of_guests: number_of_guests,
        cost: cost
    }
  end

  def valid_date_range(travel_request)
    travel_from_date = travel_request.from_date
    travel_to_date = travel_request.to_date
    if (travel_from_date and checkin_date < travel_from_date) or (travel_to_date and checkin_date > travel_to_date)
      return false
    end
    if (travel_from_date and checkout_date < travel_from_date) or (travel_to_date and checkout_date > travel_to_date)
      return false
    end
    true
  end

  protected
  def acceptable_dates?
    return if checkin_date.blank?
    return if checkout_date.blank?
    unless checkin_date <= checkout_date
      errors.add :checking_date, 'cannot be after checkout date'
    end
  end

end
