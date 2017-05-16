# == Schema Information
#
# Table name: policy_user_mappings
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  policy_id  :integer          not null
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class PolicyUserMapping < ActiveRecord::Base
  include PolicyVersion

  belongs_to :user
  belongs_to :policy

  scope :admin, -> { where admin: true }
  scope :with_policy, ->(policy_id) { where policy_id: policy_id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  # Used in PolicyUserService to get single user belonging to the policy
  scope :policy_user_map, ->(policy, user) { where policy: policy, user: user }

  validates :user_id, presence: true, uniqueness: {:scope => :policy_id}
  validates :policy_id, presence: true

end
