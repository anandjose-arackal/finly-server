class MasterRecord < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :company
  belongs_to :parent, class_name: 'MasterRecord', optional: true
end
