# == Schema Information
#
# Table name: booking_restaurants
#
#  id                      :integer          not null, primary key
#  reservation_destination :string(255)
#  reservation_date        :date
#  reservation_time        :string(255)
#  restaurant_name         :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_id               :integer
#  parent_type             :string(255)
#  restaurant_rating       :string(255)
#  start_time              :text(65535)
#  end_time                :text(65535)
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
