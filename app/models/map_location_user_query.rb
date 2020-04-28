# == Schema Information
#
# Table name: map_location_user_queries
#
#  id                     :bigint           not null
#  uuid                   :string(36)       not null, primary key
#  user_id                :bigint           not null
#  name                   :string(255)
#  address                :text(65535)
#  place_id               :string(255)
#  map_location_detail_id :integer          not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  latitude               :decimal(20, 10)
#  longitude              :decimal(20, 10)
#

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
