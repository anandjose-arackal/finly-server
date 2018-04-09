# == Schema Information
#
# Table name: travel_request_destinations
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  source            :string(255)
#  travel_request_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class TravelRequestDestination < ActiveRecord::Base
  belongs_to :travel_request

  has_many :booking_requests

  accepts_nested_attributes_for :booking_requests
end
