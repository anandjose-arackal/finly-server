# == Schema Information
#
# Table name: distances
#
#  id               :integer          not null, primary key
#  value            :decimal(10, )
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class DistanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
