# == Schema Information
#
# Table name: booking_flights
#
#  id                  :integer          not null, primary key
#  departure_date      :date
#  pnr                 :string(255)
#  airline             :string(255)
#  journey_destination :string(255)
#  journey_source      :string(255)
#  booking_id          :integer
#  booking_request_id  :integer
#  booking_type_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class BookingFlight < ActiveRecord::Base
  belongs_to :booking
  belongs_to :booking_request
  belongs_to :booking_type
end
