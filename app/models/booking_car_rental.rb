# == Schema Information
#
# Table name: booking_car_rentals
#
#  id                     :integer          not null, primary key
#  journey_source         :string(255)
#  journey_destination    :string(255)
#  pickup_address         :text(65535)
#  journey_date           :date
#  pickup_time            :string(255)
#  reservation_start_date :date
#  reservation_end_date   :date
#  car_type               :string(255)
#  car_number             :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_id              :integer
#  parent_type            :string(255)
#

class BookingCarRental < ActiveRecord::Base
  validates :journey_source, presence: true
  validates :journey_destination, presence: true
  validates :journey_date, presence: true

  belongs_to :parent, polymorphic: true
end
