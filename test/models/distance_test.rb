# == Schema Information
#
# Table name: distances
#
#  id               :integer          not null, primary key
#  value            :decimal(10, 4)
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class DistanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @valid_params = {value: "200"}
  end

  test "successfully creating a distance object" do
    assert_difference 'Distance.count' do
      @distance = Distance.create(@valid_params)
    end

    assert_equal 200, @distance.value
    assert Distance.exists?(@distance.id)
    assert_equal PhysicalUnit.kilometre_id, @distance.physical_unit_id
  end

  test "the default unit for distance creation is kilometre" do

  end
end
