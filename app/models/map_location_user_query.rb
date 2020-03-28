class MapLocationUserQuery < ApplicationRecord
  include UUIDHelper

  belongs_to :user
  belongs_to :map_location_detail

  def as_json(options = {})
    {
        name: name,
        address: address,
        description: "#{name}, #{address}",
        maps_id: place_id,
        latitude: latitude,
        longitude: longitude
    }
  end

end
