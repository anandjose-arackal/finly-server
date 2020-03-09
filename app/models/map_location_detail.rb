class MapLocationDetail < ApplicationRecord
  include UUIDHelper

  serialize :result, JSON
end
