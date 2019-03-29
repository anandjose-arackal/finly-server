class PolicyDepartmentMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :department, optional: true
end
