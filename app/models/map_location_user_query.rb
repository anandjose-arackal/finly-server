class MapLocationUserQuery < ApplicationRecord
  include UUIDHelper

  belongs_to :user
  belongs_to :map_location_detail

  def as_json(options = {})
    {
        place_id: place_id,
        name: name,
        address: address
    }
  end

end
