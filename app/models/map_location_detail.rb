class MapLocationDetail < ApplicationRecord
  include UUIDHelper

  serialize :result, JSON

  def as_json(options = {})
    {
        name: name,
        address: address,
        place_id: place_id,
        latitude: latitude,
        longitude: longitude
    }
  end
end
