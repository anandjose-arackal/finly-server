# == Schema Information
#
# Table name: policy_user_mappings
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  policy_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PolicyUserMapping < ActiveRecord::Base
  include PolicyVersion

  belongs_to :user
  belongs_to :policy

  scope :policy, ->(policy_id) { where policy_id: policy_id }
  scope :user, ->(user_id) { where user_id: user_id }
  # Used in PolicyUserService to get single user belonging to the policy
  scope :policy_user_map, ->(policy, user) { find_by policy: policy, user: user }
end
