# action to delete particular user roles of a user
# params:
# user_id: id of the user whose roles are to be updated
#

class User::Role::Destroy < BaseOperation

  attr_accessor :being_updated_user, :roles_to_remove

  def authorized_user_types
    [:admin]
  end

  def init
    self.being_updated_user = user.companies.find_by(id: params[:user_id])
    self.roles_to_remove = params[:user_role_id]
  end

  def authorize
    unless being_updated_user
      raise_unauthorized_exception
    end
  end

  def validate
    roles_to_remove.each do |role|
      team = User::Team::Index.new(being_updated_user, role_id: role).run.team
      unless team.blank?
        errors << "#{being_updated_user.name} has other team members under him. "
        return false
      end
    end
  end

  def process
    unless user.role_mapping.role(roles_to_remove).destroy_all
      errors << user.role_mapping.errors.full_messages
      return false
    end
  end


  def post_process
    # mailer
  end

  def success
    true
  end
end