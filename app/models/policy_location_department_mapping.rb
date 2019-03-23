class PolicyLocationDepartmentMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :location, optional: true
  belongs_to :department, optional: true
end
