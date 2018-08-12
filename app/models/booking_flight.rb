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
#  journey_date        :date
#  booking_class       :string(255)
#  stops               :string(255)
#  ticket_number       :string(255)
#  start_time          :text(65535)
#  end_time            :text(65535)
#

class BookingFlight < ActiveRecord::Base
  validates :journey_source, presence: true
  validates :journey_destination, presence: true
  validates :journey_date, presence: true

  belongs_to :parent, polymorphic: true

end
