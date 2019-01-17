class PolicyUserRoleMappings::Create < PolicyUserRoleMappings::Base
  attr_accessor :policy_user_role_mapping_params

  def init
    super
    self.policy_user_role_mapping_params = policy_user_role_mapping_parameters
  end

  def process
    self.policy_user_role_mapping = self.policy.policy_user_role_mappings.new(policy_user_role_mapping_params)

    if self.policy_user_role_mapping.save
      add_message :success, "Successfully added user"
    end
  end

  private
  def policy_user_role_mapping_parameters
    params.require(:policy_user_role_mapping).permit(:role_id, :user_id)
  end
end