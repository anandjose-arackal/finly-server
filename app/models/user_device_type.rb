# == Schema Information
#
# Table name: user_device_types
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserDeviceType < ApplicationRecord
  include Seedable

  def self.values
    [:browser, :android_app, :ios_app, :api]
  end

end
