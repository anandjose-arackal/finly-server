# == Schema Information
#
# Table name: booking_buses
#
#  id                  :integer          not null, primary key
#  journey_source      :string(255)
#  journey_destination :string(255)
#  journey_date        :date
#  departure_time      :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  parent_type         :string(255)
#  boarding_point      :string(255)
#  booking_class       :string(255)
#  start_time          :text(65535)
#  end_time            :text(65535)
#

class BookingBus < ActiveRecord::Base
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

  def as_json(options = {})
    {
        id: id,
        booking_class: booking_class,
        from: from,
        to: to,
        departure_date: DateUtils.date_formatted(departure_date),
        departure_time: DateUtils.time_formatted(departure_time, military_time: true),
        arrival_date: DateUtils.date_formatted(arrival_date),
        arrival_time: DateUtils.time_formatted(arrival_time, military_time: true),
        cost: cost,
        boarding_point: boarding_point,
        drop_point: drop_point,
        description: description
    }
  end
end

