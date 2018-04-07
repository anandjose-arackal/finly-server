class TravelRequestDestination < ActiveRecord::Base
  belongs_to :travel_request

  has_many :booking_requests
end
