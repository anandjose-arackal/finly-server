class PolicyLocationMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :location, optional: true, class_name: 'BranchLocation'
end
