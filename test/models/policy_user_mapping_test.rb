# == Schema Information
#
# Table name: policy_user_mappings
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  policy_id  :integer          not null
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE), not null
#


require 'test_helper'

class PolicyUserMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
