class UserDeviceType < ApplicationRecord
  include Seedable

  def self.values
    [:web, :android_app, :ios_app, :api]
  end

end
