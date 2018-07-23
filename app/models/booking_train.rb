# == Schema Information
#
# Table name: booking_trains
#
#  id                  :integer          not null, primary key
#  train_number        :string(255)
#  pnr                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  parent_type         :string(255)
#  booking_class       :string(255)
#  boarding_city_id    :integer          not null
#  boarding_station    :string(255)
#  destination_city_id :integer          not null
#  destination_station :string(255)
#  departure_datetime  :datetime
#  arrival_datetime    :datetime
#  description         :string(255)
#  seat_number         :string(255)
#  cost_id             :integer
#

class BookingTrain < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount'
  belongs_to :boarding_city, class_name: 'Location'
  belongs_to :destination_city, class_name: 'Location'

  def as_json(options={})
    {
        id: id,
        train_number: train_number,
        pnr: pnr,
        booking_class: booking_class,
        boarding_city: boarding_city,
        boarding_station: boarding_station,
        destination_city: destination_city,
        destination_station: destination_station,
        departure_datetime: departure_datetime,
        arrival_datetime: arrival_datetime,
        description: description,
        seat_number: seat_number,
        cost: cost
    }
  end

end
