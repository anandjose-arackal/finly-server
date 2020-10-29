class MasterRecord < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :company
end
