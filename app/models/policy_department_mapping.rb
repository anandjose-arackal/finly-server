# == Schema Information
#
# Table name: policy_department_mappings
#
#  id            :bigint(8)        not null, primary key
#  policy_id     :integer
#  department_id :integer
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PolicyDepartmentMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :department, optional: true


  # To choose enabled mapping by default
  # Helpful in :joins
  # default_scope { where(enabled: true) }
  scope :enabled, -> { where enabled: true }
end
