class GstLocation < ApplicationRecord

  belongs_to :state, optional: true
  has_one :gst
end
