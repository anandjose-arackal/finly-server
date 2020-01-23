# == Schema Information
#
# Table name: booking_flight_classes
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#

class BookingFlightClass < ApplicationRecord
  include Seedable

  def self.values
    [:economy, :business]
  end

  def as_json(options={})
    {
        id: id,
        name: name&.humanize
    }
  end

end
