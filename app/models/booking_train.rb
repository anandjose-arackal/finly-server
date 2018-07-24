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
#  from_id             :integer          not null
#  boarding_station    :string(255)
#  to_id               :integer          not null
#  destination_station :string(255)
#  departure_datetime  :datetime
#  arrival_datetime    :datetime
#  description         :string(255)
#  seat_number         :string(255)
#  cost_id             :integer
#  is_deleted          :boolean          default(FALSE)
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
  validates :departure_datetime, presence: true

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
        departure_datetime: DateUtils.datetime_formatted(departure_datetime),
        arrival_datetime: arrival_datetime,
        description: description,
        seat_number: seat_number,
        cost: cost
    }
  end

end
