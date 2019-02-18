class UserDeviceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :incomplete]
  end

end
