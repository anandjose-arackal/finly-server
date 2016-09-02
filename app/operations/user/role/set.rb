# action to update the roles of a particular user
# params
# user_id: id of the user being updated
# user_role_id: all the role ids the user will hence be a part of

class User::Role::Set < BaseOperation
  attr_accessor :roles_to_add, :roles_to_remove, :being_updated_user

  def pre_validate
    unless params[:user_id].present?
      errors << 'User not found'
    end
  end

  def pre_authorize
    unless user.company_admin?
      raise_unauthorized_exception
    end
  end

  def init
    self.being_updated_user = user.company.users.with_id(params[:user_id]).first rescue nil
    return unless being_updated_user.present?
    existing_role_ids = being_updated_user.role_mapping.map(&:user_role_id)
    new_role_ids = params[:user_role_id]
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    self.roles_to_add = new_role_ids - existing_role_ids
    self.roles_to_remove = existing_role_ids - new_role_ids
  end


  def process
    return unless roles_to_add.present? or roles_to_remove.present?
    create = []
    roles_to_add.each do |role_id|
      create << {user_id: updating_user.id, user_role_id: role_id}
    end
    UserRoleMapping.create(create) if create.present?
    being_updated_user.role_mapping.with_id(roles_to_remove).destroy_all if roles_to_remove.present?
  end

end