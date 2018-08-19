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
#

class BookingRestaurant < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :location, dependent: :destroy

  accepts_nested_attributes_for :location

  validates :location, presence: true
  validates :restaurant_name, presence: true
  validates :number_of_guests, presence: true
  validates :reservation_date, presence: true
  validates :reservation_time, presence: true

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

end
