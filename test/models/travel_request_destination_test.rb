# == Schema Information
#
# Table name: travel_request_destinations
#
#  id                :integer          not null, primary key
#  travel_request_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  location_id       :integer
#

require 'test_helper'

class TravelRequestDestinationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
