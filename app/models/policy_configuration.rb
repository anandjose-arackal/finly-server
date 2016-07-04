class PolicyConfiguration < ActiveRecord::Base
  include PolicyVersion
  belongs_to :policy

  scope :for_policy, ->(policy_id){find_by id: policy_id}
end
