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

class EnforcePolicy < ActiveRecord::Base

  belongs_to :enforceable, polymorphic: true

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
