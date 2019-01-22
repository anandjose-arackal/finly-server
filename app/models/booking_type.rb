# == Schema Information
#
# Table name: booking_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookingType < ApplicationRecord
  include Seedable

  def self.values
    [:flight, :car_rental, :bus, :train, :hotel, :restaurant, :others]
  end

  def flight?
    self.id == BookingType.id_for(:flight)
  end

  def train?
    self.id == BookingType.id_for(:train)
  end

  def bus?
    self.id == BookingType.id_for(:bus)
  end

  def car_rental?
    self.id == BookingType.id_for(:car_rental)
  end

  def hotel?
    self.id == BookingType.id_for(:hotel)
  end

  def restaurant?
    self.id == BookingType.id_for(:restaurant)
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
