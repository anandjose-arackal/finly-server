# == Schema Information
#
# Table name: user_wallet_tracks
#
#  id                          :integer          not null, primary key
#  user_wallet_id              :integer          not null
#  user_wallet_track_action_id :integer          not null
#  amount_id                   :integer          not null
#  action_user_id              :integer          not null
#  balance_after_action_id     :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

require 'test_helper'

class UserWalletTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
