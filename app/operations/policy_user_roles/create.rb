class PolicyUserRoles::Create < PolicyUserRoles::Base
  attr_accessor :policy_user_role_params

  def init
    super
    self.policy_user_role_params = policy_user_role_parameters
  end

  def process
    self.policy_user_role = self.policy.policy_user_roles.new(policy_user_role_params)

    if self.policy_user_role.save
      add_message :success, "Successfully added user"
    end
  end

  private
  def policy_user_role_parameters
    params.require(:policy_user_role).permit(:role_id, :user_id)
  end
end