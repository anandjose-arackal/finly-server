# == Schema Information
#
# Table name: policy_user_roles
#
#  id           :integer          not null, primary key
#  policy_id    :integer
#  user_id      :integer
#  user_role_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  min_amount   :decimal(20, 5)   default(0.0)
#  max_amount   :decimal(20, 5)
#

require 'test_helper'

class PolicyUserRoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
