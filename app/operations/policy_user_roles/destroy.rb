class PolicyUserRoles::Destroy < PolicyUserRoles::Base
  attr_accessor :added_users, :role_id, :policy_user_role

  def init
    id = params[:id] || params[:policy_user_role_id]
    self.policy_user_role = PolicyUserRoles::Index.(user, params).policy_user_roles.find_by(id: id) rescue nil
  end

  def validate
    unless self.policy_user_role.present?
      add_message :error, 'Record not found'
    end
  end

  def process
    if self.policy_user_role.destroy
      add_message :success, "Successfully removed user"
    else
      add_message :error, "Couldn't removed user"
    end
  end
end