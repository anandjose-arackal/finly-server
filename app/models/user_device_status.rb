# == Schema Information
#
# Table name: user_device_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserDeviceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :incomplete]
  end

end
