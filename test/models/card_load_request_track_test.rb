# == Schema Information
#
# Table name: card_load_request_tracks
#
#  id                           :integer          not null, primary key
#  card_load_request_id         :integer          not null
#  action_user_id               :integer
#  card_load_tracking_action_id :integer
#  status_id                    :integer
#  user_request_role_id         :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  action_id                    :integer
#

require 'test_helper'

class CardLoadRequestTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
