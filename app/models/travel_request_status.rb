class TravelRequestStatus < ActiveRecord::Base

  include Seedable

  def self.values
    [] #todo populate statuses and seed
  end
end
