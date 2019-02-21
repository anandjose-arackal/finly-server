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
    unless user.company_admin? || user.vendor_payments_admin?
      raise_unauthorized_exception
    end
  end

  def init
    id = (params[:id] or params[:user_id])
    self.being_updated_user = user.company.users.with_id(id).first rescue nil
    return unless being_updated_user.present?
    self.purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])

    if funds_transfer?
      existing_role_ids = being_updated_user.role_mapping.with_purpose(purpose_id).only_admin_and_finance.map(&:user_role_id)
    else
      existing_role_ids = being_updated_user.role_mapping.with_purpose(purpose_id).map(&:user_role_id)
    end
    # extracting auditor roles here becuase it's purpose agnostic
    existing_role_ids += being_updated_user.role_mapping.auditor.map(&:user_role_id)

    new_role_ids = params[:user_role_id]
    if new_role_ids.blank? and params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.id_for(:admin) if params[:user_roles][:admin].present? and ['1', 'true'].include?(params[:user_roles][:admin].to_s)
      new_role_ids << UserRole.manager_id if params[:user_roles][:manager].present? and
          ['1', 'true'].include?(params[:user_roles][:manager].to_s)
      if params[:user_roles][:finance_manager].present? and ['1', 'true'].include?(params[:user_roles][:finance_manager].to_s)
        if expense_management?
          new_role_ids << UserRole.finance_manager_id
        else
          new_role_ids << UserRole.id_for(:creditor)
        end
      end
      new_role_ids << UserRole.id_for(:auditor) if params[:user_roles][:auditor].present? and
          params[:user_roles][:auditor].to_s == '1'
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

    if roles_to_remove.present?
      being_updated_user.role_mapping.with_purpose(purpose_id).role(roles_to_remove).each do |role_mapping|
        role_mapping.destroy
      end
    end

    # destroying auditor roles if required, because they're purpose agnostic
    if roles_to_remove.include?(UserRole.id_for(:auditor))
      being_updated_user.role_mapping.role(UserRole.id_for(:auditor)).destroy_all
    end
  end

  def post_process
    messages[:success] << 'Role updated!'
  end

end