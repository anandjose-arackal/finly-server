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
  validates :journey_source, presence: true
  validates :journey_destination, presence: true
  validates :journey_date, presence: true

  belongs_to :parent, polymorphic: true

end
