class IndexViewSegment < ApplicationRecord
  include UUIDHelper

  belongs_to :user
  belongs_to :company

  serialize :filters, JSON
  serialize :columns, JSON
end
