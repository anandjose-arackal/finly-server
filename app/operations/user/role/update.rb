# action to update a user's role in the company
# params:
# user_id: id of the user being updated
# user_role_id: ids of the user roles that the user needs to be added to

class User::Role::Update < BaseOperation

  attr_accessor :being_updated_user, :roles

  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.being_updated_user = user.company.users.find_by(id: params[:user_id])
    self.roles = being_updated_user.roles
  end

  def authorize
    unless being_updated_user
      raise_unauthorized_exception
    end
  end

  def process
    existing_role_ids = user.role_mapping.map(&:user_role_id)
    new_role_ids = params[:user_role_id]
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    roles_to_add = new_role_ids - existing_role_ids
    roles_to_add.each do |role_id|
      unless user.role_mapping.create(user_role_id: role_id)
        messages[:error] = user.role_mapping.errors.full_messages
        return false
      end
    end
    true
  end

  def post_process
    # mailer
  end

  # return true if the updation was a success
  def success
    return true
  end
end