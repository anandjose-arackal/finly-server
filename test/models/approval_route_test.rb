# == Schema Information
#
# Table name: approval_routes
#
#  id                 :integer          not null, primary key
#  purpose_id         :integer          not null
#  level              :integer          not null
#  reviewer_id        :integer          not null
#  threshold          :integer          default(0), not null
#  created_by_user_id :integer          not null
#  user_id            :integer
#  policy_id          :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class ApprovalRouteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
