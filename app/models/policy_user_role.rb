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
#

class PolicyUserRole < ActiveRecord::Base
  belongs_to :policy
  belongs_to :user
  belongs_to :user_role

  scope :with_user_id, -> (user_id) {
    where user_id: user_id
  }

  scope :with_role_id, -> (role_id){
    where user_role_id: role_id
  }

  scope :filter_role_id, -> (role_id) {
    with_role_id(role_id)
  }
end
