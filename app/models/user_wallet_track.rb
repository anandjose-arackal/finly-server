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

class UserWalletTrack < ApplicationRecord
  belongs_to :user_wallet, optional: true
  belongs_to :user_wallet_track_action, optional: true
  belongs_to :amount, optional: true
  belongs_to :action_user, optional: true, class_name: 'User'
  belongs_to :balance_after_action, optional: true, class_name: 'Amount'
end
