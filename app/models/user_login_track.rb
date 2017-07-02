# == Schema Information
#
# Table name: user_login_tracks
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  ip_address  :string(255)
#  referrer    :string(255)
#  application :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserLoginTrack < ActiveRecord::Base
  belongs_to :user
end
