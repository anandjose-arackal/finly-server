# == Schema Information
#
# Table name: vehicle_rates
#
#  id               :integer          not null, primary key
#  vehicle_name     :string(255)      not null
#  rate_id          :integer          not null
#  distance_unit_id :integer          not null
#  policy_id        :integer
#  is_deleted       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

require 'test_helper'

class VehicleRateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
