class MasterMapping < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :company

  belongs_to :from_record, polymorphic: true, optional: true
  belongs_to :to_record, polymorphic: true
end
