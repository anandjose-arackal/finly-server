class PolicyUserRoleMappings::Base < BaseOperation
  attr_accessor :policy_user_role_mapping, :policy

  def init
    policy_id = params[:policy_id]
    self.policy = Policy::Index.(current_user, params).with_id(policy_id).first rescue nil
  end

  def validate
    unless self.policy.present?
      add_message :error, "Policy not found"
    end

    unless self.policy_user_role_mapping.present?
      add_message :error, "User Role Not Found"
    end
  end
end