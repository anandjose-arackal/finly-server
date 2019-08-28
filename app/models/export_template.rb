class ExportTemplate < ApplicationRecord
  belongs_to :company
  belongs_to :created_by_user, class_name: 'User'

  serialize :configuration, JSON
end
