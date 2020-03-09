class MapLocationSearch < ApplicationRecord
  include UUIDHelper

  serialize :result, JSON
end
