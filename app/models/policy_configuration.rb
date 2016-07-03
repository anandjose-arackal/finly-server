class PolicyConfiguration < ActiveRecord::Base
  belongs_to :policy

  scope :for_policy, ->(policy_id){find_by id: policy_id}

  has_paper_trail
end
