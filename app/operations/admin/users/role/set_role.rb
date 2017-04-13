class Admin::Users::SetRole < Admin::Users::Base

  attr_accessor :roles_to_add, :roles_to_remove, :being_updated_user

  def pre_validate
    super()
    id = (params[:id] or params[:user_id])
    unless id.present?
      messages[:error] << 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:user_id])
    self.being_updated_user = User.with_id(id).first rescue nil
    return unless being_updated_user.present?
    existing_role_ids = being_updated_user.role_mapping.map(&:user_role_id)
    new_role_ids = params[:user_role_id]
    if new_role_ids.blank? and params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.admin_id if params[:user_roles][:admin].present? and
          params[:user_roles][:admin].to_s == '1'
      new_role_ids << UserRole.manager_id if params[:user_roles][:manager].present? and
          params[:user_roles][:manager].to_s == '1'
      new_role_ids << UserRole.finance_manager_id if params[:user_roles][:finance_manager].present? and
          params[:user_roles][:finance_manager].to_s == '1'
    end
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    # To ensure all users have a personal view
    new_role_ids << UserRole.id_for(:employee)
    # new_role_ids << UserRole.id_for(:admin) if (being_updated_user.company_admin? and user.id == being_updated_user.id)
    new_role_ids.uniq!
    self.roles_to_add = new_role_ids - existing_role_ids
    self.roles_to_remove = existing_role_ids - new_role_ids
  end

  def process
    return unless roles_to_add.present? or roles_to_remove.present?
    create = []
    roles_to_add.each do |role_id|
      create << {user_id: being_updated_user.id, user_role_id: role_id}
    end
    UserRoleMapping.create(create) if create.present?
    being_updated_user.role_mapping.role(roles_to_remove).destroy_all if roles_to_remove.present?
  end

  def post_process
    add_message :success, 'Role updated!'
  end

end