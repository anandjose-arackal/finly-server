# Currently only being used to update min & max amount in PUR

class PolicyUserRoles::Update < PolicyUserRoles::Base
  attr_accessor :policy_user_role_params, :added_users, :role_id

  def authorized_user_types

  end

  def init
    super
    id = params[:policy_user_role_id] || params[:id]
    self.policy_user_role = ::PolicyUserRoles::Index.(user, params).policy_user_roles.with_id(id).first rescue nil

    self.policy_user_role_params = policy_user_role_parameters
  end

  def validate
    unless self.policy_user_role.present?
      add_message :error, 'Role not found'
    end

    unless self.policy.present?
      add_message :error, 'Policy not found'
    end

    unless self.policy_user_role&.policy_id == self.policy.id
      add_message :error, "Invalid configuration"
    end
  end

  def process
    unless self.policy_user_role.update(policy_user_role_params)
      add_message :error, self.policy_user_role.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Successfully updated threshold limits"
  end

  private

  def policy_user_role_parameters
    params.require(:policy_user_role).permit(:min_amount, :max_amount)
  end
end