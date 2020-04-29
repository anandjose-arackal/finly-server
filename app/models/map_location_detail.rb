# == Schema Information
#
# Table name: map_location_details
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  icon       :string(255)
#  name       :string(255)
#  place_id   :string(255)
#  url        :string(255)
#  address    :text(4294967295)
#  result     :text(4294967295)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  latitude   :decimal(20, 10)
#  longitude  :decimal(20, 10)
#

class MapLocationDetail < ApplicationRecord
  include UUIDHelper

  serialize :result, JSON

  def as_json(options = {})
    {
        name: name,
        address: address,
        description: "#{name}, #{address}",
        maps_id: place_id,
        latitude: latitude,
        longitude: longitude,
    }
  end
end
