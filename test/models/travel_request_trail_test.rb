# == Schema Information
#
# Table name: travel_request_trails
#
#  id                       :integer          not null, primary key
#  travel_request_id        :integer
#  action_id                :integer
#  action_user_id           :integer
#  action_user_role_id      :integer
#  modified_user_id         :integer
#  modified_user_role_id    :integer
#  action_for_user_id       :integer
#  action_for_user_role_id  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_deleted               :boolean          default(FALSE)
#  delegated_action_user_id :integer
#

require 'test_helper'

class TravelRequestTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
