# == Schema Information
#
# Table name: user_wallet_track_actions
#
#  id                :integer          not null, primary key
#  CreateUserWallets :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserWalletTrackAction < ApplicationRecord
end
