# == Schema Information
#
# Table name: google_maps_configs
#
#  id         :bigint           not null, primary key
#  device     :string(255)      not null
#  api_token  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class GoogleMapsConfig < ApplicationRecord

  DEV_VALUES = {
      android: "AIzaSyC0EcUaLSYoKwcR30X39hLzLpIeSUXXFcE",
      ios: "AIzaSyC0EcUaLSYoKwcR30X39hLzLpIeSUXXFcE",
      web: "AIzaSyC0EcUaLSYoKwcR30X39hLzLpIeSUXXFcE"
  }

  def self.seed_data
    DEV_VALUES.each do |device, api_token|
      next if GoogleMapsConfig.find_by(device: device).present?

      GoogleMapsConfig.create(device: device, api_token: api_token)
    end
  end

end
