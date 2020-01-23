class TripRoute < ApplicationRecord
  belongs_to :trip
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  has_one :transport_request, class_name: "TripTransportRequest"
  has_one :hotel_request, class_name: "TripHotelRequest"
  has_one :local_conveyance_request, class_name: "TripLocalConveyanceRequest"
end
