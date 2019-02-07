# == Schema Information
#
# Table name: trails
#
#  id                        :integer          not null, primary key
#  parent_id                 :integer
#  parent_type               :string(255)
#  action_user_id            :integer
#  action_id                 :integer
#  action_user_role_id       :integer
#  action_level_id           :integer
#  modified_level_id         :integer
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  delegated_action_user_id  :integer
#  payment_id                :integer
#  original_track_type       :string(255)
#  original_track_id         :integer
#  cash_on_hand_deduction_id :integer
#

require 'test_helper'

class TrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
