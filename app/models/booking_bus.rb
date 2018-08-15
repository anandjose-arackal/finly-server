# == Schema Information
#
# Table name: booking_buses
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_id      :integer
#  parent_type    :string(255)
#  booking_class  :string(255)
#  from_id        :integer          not null
#  to_id          :integer          not null
#  cost_id        :integer
#  boarding_point :text(65535)
#  drop_point     :text(65535)
#  description    :text(65535)
#  is_deleted     :boolean          default(FALSE)
#  departure_date :date
#  departure_time :time
#  arrival_date   :date
#  arrival_time   :time
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

