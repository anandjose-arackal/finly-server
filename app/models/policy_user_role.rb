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

class PolicyUserRole < ApplicationRecord
  belongs_to :policy, optional: true
  belongs_to :user, optional: true
  belongs_to :user_role, optional: true
end
