class BookingFlightClass < ActiveRecord::Base
  include Seedable

  def self.values
    [:economy, :premium_economy, :first, :business]
  end

end
