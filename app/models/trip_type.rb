class TripType < ApplicationRecord
  include Seedable

  def self.values
    [:one_way, :round_trip, :multi_city]
  end
end
