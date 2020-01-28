# == Schema Information
#
# Table name: trip_routes
#
#  id                       :bigint           not null
#  uuid                     :string(36)       not null, primary key
#  trip_id                  :string(255)      not null
#  from_location            :string(255)
#  to_location              :string(255)
#  depart_on                :date
#  return_on                :date
#  require_transport        :boolean          default(FALSE)
#  require_hotel            :boolean          default(FALSE)
#  require_local_conveyance :boolean          default(FALSE)
#

class TripRoute < ApplicationRecord
  include UUIDHelper

  belongs_to :trip
  has_many :transport_request, class_name: "TripTransportRequest"
  has_many :hotel_request, class_name: "TripHotelRequest"
  has_many :local_conveyance_request, class_name: "TripLocalConveyanceRequest"
end
