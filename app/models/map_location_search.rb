# == Schema Information
#
# Table name: map_location_searches
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  input      :string(255)
#  result     :text(4294967295)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MapLocationSearch < ApplicationRecord
  include UUIDHelper

  serialize :result, JSON
end
