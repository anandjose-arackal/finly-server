# == Schema Information
#
# Table name: physical_units
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  symbol     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PhysicalUnitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
