class PolicyUserRoles::Create < PolicyUserRoles::Base
  attr_accessor :policy_user_role_params, :added_users, :role_id

  def authorized_user_types

  end

  def init
    super
    self.policy_user_role_params = policy_user_role_parameters

    self.role_id = policy_user_role_params[:user_role_id]

    user_ids = policy_user_role_params[:user_ids]
    unless user_ids.is_a?(Array)
      user_ids = user_ids.split(',')
    end
    self.added_users = user.company.users.with_id(user_ids)
  end

  def validate
    unless self.role_id.present?
      add_message :error, 'Role not found'
    end

    unless UserRole.pluck(:id).include? self.role_id.to_i
      add_message :error, 'Unknown Role'
    end
  end

  def process
    user_added = 0
    role_created = 0

    added_users.each do |added_user|
      policy_user_role = self.policy.policy_user_roles.new({user_role_id: role_id, user_id: added_user.id})
      policy_user_role.save

      if added_user.role_mapping.with_role_id(self.role_id).present?
        user_added += 1
      else
        if added_user.role_mapping.create(user_role_id: self.role_id)
          role_created += 1
        end

      end
    end

    add_message :success ,"#{user_added} users added as #{UserRole.name_for(role_id)} for the policy"
    add_message :success ,"#{user_added} users assigned #{UserRole.name_for(role_id)} role & added to the policy"

  end


  private
  def policy_user_role_parameters
    params.require(:policy_user_role).permit(:user_role_id, user_ids: [])
  end
end