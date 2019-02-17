class PolicyUserRoles::Base < BaseOperation
  attr_accessor :policy_user_role, :policy

  def init
    policy_id = params[:policy_id]
    self.policy = user.company.policies.with_id(policy_id).first rescue nil

    # not using policy::index as its scoped to current user's policies.
    # self.policy = Policy::Index.(user, params).policies.with_id(policy_id).first rescue nil
  end

  def validate
    unless self.policy.present?
      add_message :error, "Policy not found"
    end

    unless self.policy_user_role.present?
      add_message :error, "User Role Not Found"
    end
  end
end