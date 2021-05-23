class MasterRecord < ApplicationRecord
  include AncestrySupport
  belongs_to :created_by, class_name: 'User'
  belongs_to :company
  has_ancestry
end
