# == Schema Information
#
# Table name: booking_restaurants
#
#  id                 :integer          not null, primary key
#  restaurant_name    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_id          :integer
#  parent_type        :string(255)
#  location_id        :integer          not null
#  restaurant_address :text(65535)
#  number_of_guests   :integer
#  description        :text(65535)
#  is_deleted         :boolean          default(FALSE)
#  reservation_date   :date
#  reservation_time   :time
#  booking_id         :integer
#

class BookingRestaurant < ApplicationRecord
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation

  # belongs_to :parent, optional: true, polymorphic: true
  belongs_to :booking, optional: true, inverse_of: :booking_restaurant
  belongs_to :location, optional: true, dependent: :destroy

  accepts_nested_attributes_for :location

  validates :location, presence: true
  validates :restaurant_name, presence: true
  validates :number_of_guests, presence: true
  validates :reservation_date, presence: true
  validates :reservation_time, presence: true

  # As front end calls this comment and not description, have to give an alias for validation purpose
  alias_attribute :comment, :description

  delegate :request?, to: :booking

  field_customization_key :booking_restaurant
  customizable_validate :comment, presence: false, scope: [:booking, :travel_request, :company], if: :request?
  # validates :comment, presence: true

  def as_json(options={})
    {
        id: id,
        restaurant_name: restaurant_name,
        location: location,
        restaurant_address: restaurant_address,
        reservation_date: DateUtils.date_formatted(reservation_date),
        reservation_time: DateUtils.time_formatted(reservation_time, military_time: true),
        number_of_guests: number_of_guests,
        description: description
    }
  end

  def valid_date_range(travel_request)
    travel_from_date = travel_request.from_date
    travel_to_date = travel_request.to_date
    return false if travel_from_date and reservation_date < travel_from_date
    return false if travel_to_date and reservation_date > travel_to_date
    true
  end

end
