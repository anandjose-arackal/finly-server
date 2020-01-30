# == Schema Information
#
# Table name: trip_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TripType < ApplicationRecord
  include Seedable

  def self.values
    [:one_way, :round_trip, :multi_city]
  end
end
