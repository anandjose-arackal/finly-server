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
#

class BookingHotel < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :location, dependent: :destroy

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :cost

  validates :location, presence: true
  validates :checkin_date, presence: true
  validates :checkout_date, presence: true
  validate :acceptable_dates?

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
    if checkin_date < travel_from_date or checkin_date > travel_to_date
      return false
    end
    if checkout_date < travel_from_date or checkout_date > travel_to_date
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
