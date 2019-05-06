# == Schema Information
#
# Table name: user_branch_location_mappings
#
#  id                 :bigint           not null, primary key
#  user_id            :integer          not null
#  branch_location_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class UserBranchLocationMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
