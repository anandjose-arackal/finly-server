# == Schema Information
#
# Table name: booking_trains
#
#  id                    :integer          not null, primary key
#  journey_source        :string(255)
#  journey_destination   :string(255)
#  journey_date          :date
#  departure_time        :string(255)
#  train_number          :string(255)
#  pnr                   :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  parent_id             :integer
#  parent_type           :string(255)
#  booking_class         :string(255)
#  boarding_station_name :string(255)
#  start_time            :text(65535)
#  end_time              :text(65535)
#

class BookingTrain < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :from, class_name: 'Location', dependent: :destroy
  belongs_to :to, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :from
  accepts_nested_attributes_for :to
  accepts_nested_attributes_for :cost

  validates :from, presence: true
  validates :to, presence: true
  validates :departure_date, presence: true
  validates :departure_time, presence: true

  def as_json(options={})
    {
        id: id,
        train_number: train_number,
        pnr: pnr,
        booking_class: booking_class,
        from: from,
        boarding_station: boarding_station,
        to: to,
        destination_station: destination_station,
        departure_date: DateUtils.date_formatted(departure_date),
        departure_time: DateUtils.time_formatted(departure_time, military_time: true),
        arrival_date: DateUtils.date_formatted(arrival_date),
        arrival_time: DateUtils.time_formatted(arrival_time, military_time: true),
        description: description,
        seat_number: seat_number,
        cost: cost
    }
  end

end
