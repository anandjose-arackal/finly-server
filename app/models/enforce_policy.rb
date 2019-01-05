# == Schema Information
#
# Table name: enforce_policies
#
#  id               :integer          not null, primary key
#  enabled          :boolean
#  enforceable_id   :integer
#  enforceable_type :string(255)
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
      if user.policies.non_default.empty?
        errors.add(:user, "needs to beong to at least one non-default policy")
      end
    end
  end
end
