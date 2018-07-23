# == Schema Information
#
# Table name: booking_flights
#
#  id                 :integer          not null, primary key
#  pnr                :string(255)
#  airline            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_id          :integer
#  parent_type        :string(255)
#  stops              :string(255)
#  ticket_number      :string(255)
#  from_id            :integer          not null
#  to_id              :integer          not null
#  departure_datetime :datetime
#  arrival_datetime   :datetime
#  description        :text(65535)
#  terminal           :string(255)
#  cost_id            :integer
#  booking_class_id   :integer
#

class BookingFlight < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :booking_class, class_name: 'BookingFlightClass'
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :from, class_name: 'Location', dependent: :destroy
  belongs_to :to, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :from
  accepts_nested_attributes_for :to
  accepts_nested_attributes_for :cost

  validates :from, presence: true
  validates :to, presence: true
  validates :departure_datetime, presence: true


  def as_json(options={})
    {
        id: id,
        pnr: pnr,
        airline: airline,
        stops: stops,
        ticket_number: ticket_number,
        from: from,
        to: to,
        departure_datetime: DateUtils.datetime_formatted(departure_datetime),
        arrival_datetime: DateUtils.datetime_formatted(arrival_datetime),
        description: description,
        terminal: terminal,
        cost: cost,
        booking_class: booking_class
    }
  end
end
