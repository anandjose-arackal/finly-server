# == Schema Information
#
# Table name: policy_user_roles
#
#  id           :integer          not null, primary key
#  policy_id    :integer
#  user_id      :integer
#  user_role_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  min_amount   :decimal(20, 5)   default(0.0)
#  max_amount   :decimal(20, 5)
#

class PolicyUserRole < ApplicationRecord
  belongs_to :policy, optional: true
  belongs_to :user, optional: true
  belongs_to :user_role, optional: true

  scope :with_user_id, -> (user_id) {
    where user_id: user_id
  }

  scope :with_role_id, -> (role_id){
    where user_role_id: role_id
  }

  scope :filter_role_id, -> (role_id) {
    with_role_id(role_id)
  }

  scope :with_policy_id, -> (policy_id){
    where policy_id: policy_id
  }
end
