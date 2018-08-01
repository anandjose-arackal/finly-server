# == Schema Information
#
# Table name: booking_car_rentals
#
#  id             :integer          not null, primary key
#  pickup_address :text(65535)
#  car_type       :string(255)
#  car_number     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_id      :integer
#  parent_type    :string(255)
#  pickup_city_id :integer          not null
#  drop_city_id   :integer          not null
#  drop_address   :text(65535)
#  rental_company :string(255)
#  description    :text(65535)
#  cost_id        :integer
#  pickup_date    :date
#  pickup_time    :time
#  drop_date      :date
#  drop_time      :time
#

class BookingCarRental < ActiveRecord::Base
  validates :journey_source, presence: true
  validates :journey_destination, presence: true
  validates :journey_date, presence: true

  belongs_to :parent, polymorphic: true
end
