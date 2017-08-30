# action to update the roles of a particular user
# params
# user_id: id of the user being updated
# user_role_id: all the role ids the user will hence be a part of

class User::Role::Set < BaseOperation
  attr_accessor :roles_to_add, :roles_to_remove, :being_updated_user, :purpose_id

  def pre_validate
    id = (params[:id] or params[:user_id])
    unless id.present?
      messages[:error] << 'User not found'
    end
  end

  def pre_authorize
    unless user.company_admin?
      raise_unauthorized_exception
    end
  end

  def init
    id = (params[:id] or params[:user_id])
    self.being_updated_user = user.company.users.with_id(id).first rescue nil
    return unless being_updated_user.present?
    self.purpose_id = MappingPurpose.id_from_application_for(RequestStore.store[:current_app])
    existing_role_ids = being_updated_user.role_mapping.with_purpose(purpose_id).map(&:user_role_id)
    new_role_ids = params[:user_role_id]
    if new_role_ids.blank? and params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.id_for(:admin) if params[:user_roles][:admin].present? and ['1', 'true'].include?(params[:user_roles][:admin].to_s)
      new_role_ids << UserRole.manager_id if params[:user_roles][:manager].present? and
          ['1', 'true'].include?(params[:user_roles][:manager].to_s)
      new_role_ids << UserRole.finance_manager_id if params[:user_roles][:finance_manager].present? and
          ['1', 'true'].include?(params[:user_roles][:finance_manager].to_s)
      # adding initiator role if it's present in the params
      new_role_ids << UserRole.id_for(:initiator) if params[:user_roles][:initiator].present? && ['1', 'true'].include?(params[:user_roles][:initiator])
    end
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    # To ensure all users have a personal view, only in expense management
    if expense_management?
      new_role_ids << UserRole.id_for(:employee)
    end
    # new_role_ids << UserRole.id_for(:admin) if (being_updated_user.company_admin? and user.id == being_updated_user.id)
    new_role_ids.uniq!
    self.roles_to_add = new_role_ids - existing_role_ids
    self.roles_to_remove = existing_role_ids - new_role_ids
  end

  def process
    return unless roles_to_add.present? or roles_to_remove.present?
    create = []
    roles_to_add.each do |role_id|
      create << {user_id: being_updated_user.id,
                 user_role_id: role_id,
                 purpose_id: purpose_id}
    end
    UserRoleMapping.create(create) if create.present?
    being_updated_user.role_mapping.with_purpose(purpose_id).role(roles_to_remove).destroy_all if roles_to_remove.present?
  end

  def post_process
    messages[:success] << 'Role updated!'
  end

end