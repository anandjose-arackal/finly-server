# == Schema Information
#
# Table name: booking_hotels
#
#  id                      :integer          not null, primary key
#  reservation_destination :string(255)
#  reservation_start_date  :date
#  reservation_time        :string(255)
#  reservation_end_date    :date
#  hotel_name              :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_id               :integer
#  parent_type             :string(255)
#  hotel_rating            :string(255)
#  start_time              :text(65535)
#  end_time                :text(65535)
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

  protected
  def acceptable_dates?
    return if checkin_date.blank?
    return if checkout_date.blank?
    unless checkin_date <= checkout_date
      errors.add :checking_date, 'cannot be after checkout date'
    end
  end

end
