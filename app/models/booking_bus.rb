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
  validates :journey_source, presence: true
  validates :journey_destination, presence: true
  validates :journey_date, presence: true

  belongs_to :parent, polymorphic: true
end

