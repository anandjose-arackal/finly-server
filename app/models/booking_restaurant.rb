# == Schema Information
#
# Table name: booking_restaurants
#
#  id                   :integer          not null, primary key
#  restaurant_name      :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  parent_id            :integer
#  parent_type          :string(255)
#  location_id          :integer          not null
#  restaurant_address   :text(65535)
#  reservation_datetime :datetime
#  number_of_guests     :integer
#  description          :text(65535)
#

class BookingRestaurant < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :location, dependent: :destroy

  def as_json(options={})
    {
        id: id,
        restaurant_name: restaurant_name,
        location: location,
        restaurant_address: restaurant_address,
        reservation_datetime: reservation_datetime,
        number_of_guests: number_of_guests,
        description: description
    }
  end

end
