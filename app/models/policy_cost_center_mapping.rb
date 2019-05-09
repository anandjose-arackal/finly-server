class PolicyCostCenterMapping < ApplicationRecord

  belongs_to :policy, optional: true
  belongs_to :cost_center, optional: true
end
