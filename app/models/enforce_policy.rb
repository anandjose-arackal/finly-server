# == Schema Information
#
# Table name: enforce_policies
#
#  id               :integer          not null, primary key
#  enforceable_id   :integer          not null
#  enforceable_type :string(255)      not null
#  enabled          :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class EnforcePolicy < ApplicationRecord

  belongs_to :enforceable, optional: true, polymorphic: true

  validate :at_least_one_default_policy

  private

  def at_least_one_default_policy
    if self.enforceable_type == "User" && self.enabled
      user = self.enforceable
      unless user.policies.non_default.present? || has_any_policy_role(user)
        errors.add(:user, "needs to belong to at least one non-default policy")
      end
    end
  end

  def has_any_policy_role(user)
    user.company&.policies&.exclude_deleted&.joins(:policy_user_roles)&.where('policy_user_roles.user_id = ?', user.id).present?
  end
end
