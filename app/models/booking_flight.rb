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
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  parent_type         :string(255)
#

class BookingFlight < ActiveRecord::Base

  belongs_to :parent, polymorphic: true

end
