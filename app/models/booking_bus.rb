# == Schema Information
#
# Table name: booking_buses
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_id          :integer
#  parent_type        :string(255)
#  booking_class      :string(255)
#  from_id            :integer          not null
#  to_id              :integer          not null
#  departure_datetime :datetime         not null
#  arrival_datetime   :datetime
#  cost_id            :integer
#  boarding_point     :text(65535)
#  drop_point         :text(65535)
#  description        :text(65535)
#

class BookingBus < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount'
  belongs_to :from, class_name: 'Location'
  belongs_to :to, class_name: 'Location'

  def as_json(options = {})
    {
        id: id,
        booking_class: booking_class,
        from: from,
        to: to,
        departure_datetime: departure_datetime,
        arrival_datetime: arrival_datetime,
        cost: cost,
        boarding_point: boarding_point,
        drop_point: drop_point,
        description: description
    }
  end
end

