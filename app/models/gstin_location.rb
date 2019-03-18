class GstinLocation < ApplicationRecord
  belongs_to :gstin
  belongs_to :state
end
