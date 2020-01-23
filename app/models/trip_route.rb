# == Schema Information
#
# Table name: trip_routes
#
#  id                       :bigint           not null, primary key
#  uuid                     :string(36)       not null
#  trip_id                  :bigint           not null
#  from_location_id         :integer
#  to_location_id           :integer
#  depart_on                :date
#  return_on                :date
#  require_transport        :boolean          default(FALSE)
#  require_hotel            :boolean          default(FALSE)
#  require_local_conveyance :boolean          default(FALSE)
#

class TripRoute < ApplicationRecord
  belongs_to :trip
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  has_one :transport_request, class_name: "TripTransportRequest"
  has_one :hotel_request, class_name: "TripHotelRequest"
  has_one :local_conveyance_request, class_name: "TripLocalConveyanceRequest"
end
