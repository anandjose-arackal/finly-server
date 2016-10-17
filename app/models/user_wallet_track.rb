class UserWalletTrack < ActiveRecord::Base
  belongs_to :user_wallet
  belongs_to :user_wallet_track_action
  belongs_to :amount
  belongs_to :action_user, class_name: 'User'
  belongs_to :balance_after_action, class_name: 'Amount'
end