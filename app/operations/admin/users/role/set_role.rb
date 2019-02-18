class Admin::Users::Role::SetRole < Admin::Users::Base

  attr_accessor :roles_to_add_em, :roles_to_remove_em, :roles_to_add_vp, :roles_to_remove_vp, :being_updated_user, :em_purpose_id,
                :em_role_params, :vp_role_params, :vp_purpose_id, :fc_purpose_id, :fc_role_params, :roles_to_add_fc, :roles_to_remove_fc

  def pre_validate
    super()
    id = (params[:id] or params[:user_id])
    unless id.present?
      messages[:error] << 'User not found'
    end
  end

  def init

    self.em_role_params = params[:roles_em] || {}
    self.vp_role_params = params[:roles_vp] || {}
    self.fc_role_params = params[:roles_fc] || {}

    id = (params[:id] or params[:user_id])
    self.being_updated_user = User.with_id(id).first rescue nil
    return unless being_updated_user.present?

    ###### setting the expense management roles first ############
    self.em_purpose_id = Purpose.id_for(:expense_management)

    existing_role_ids = being_updated_user.role_mapping.expense_management.map(&:user_role_id)
    new_role_ids = em_role_params[:user_role_id]
    if new_role_ids.blank? and em_role_params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.admin_id if em_role_params[:user_roles][:admin].present? and
          em_role_params[:user_roles][:admin].to_s == '1'
      new_role_ids << UserRole.manager_id if em_role_params[:user_roles][:manager].present? and
          em_role_params[:user_roles][:manager].to_s == '1'
      new_role_ids << UserRole.finance_manager_id if em_role_params[:user_roles][:finance_manager].present? and
          em_role_params[:user_roles][:finance_manager].to_s == '1'
      new_role_ids << UserRole.id_for(:auditor) if em_role_params[:user_roles][:auditor].present? and
          em_role_params[:user_roles][:auditor].to_s == '1'
      new_role_ids << UserRole.id_for(:travel_manager) if em_role_params[:user_roles][:travel_manager].present? and
          em_role_params[:user_roles][:travel_manager].to_s == '1'
    end
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    # To ensure all users have a personal view
    new_role_ids << UserRole.id_for(:employee)
    # new_role_ids << UserRole.id_for(:admin) if (being_updated_user.company_admin? and user.id == being_updated_user.id)
    new_role_ids.uniq!
    self.roles_to_add_em = new_role_ids - existing_role_ids
    self.roles_to_remove_em = existing_role_ids - new_role_ids
    ##############################################################


    ###### setting the vendor payment roles ######################
    self.vp_purpose_id = Purpose.id_for(:vendor_payments)

    existing_role_ids = being_updated_user.role_mapping.vendor_payments.map(&:user_role_id)
    new_role_ids = vp_role_params[:user_role_id]
    if new_role_ids.blank? and vp_role_params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.id_for(:admin) if vp_role_params[:user_roles][:admin].present? and
          vp_role_params[:user_roles][:admin].to_s == '1'
      new_role_ids << UserRole.id_for(:reviewer) if vp_role_params[:user_roles][:reviewer].present? and
          vp_role_params[:user_roles][:reviewer].to_s == '1'
      new_role_ids << UserRole.id_for(:creditor) if vp_role_params[:user_roles][:creditor].present? and
          vp_role_params[:user_roles][:creditor].to_s == '1'
      new_role_ids << UserRole.id_for(:auditor) if vp_role_params[:user_roles][:auditor].present? and
          vp_role_params[:user_roles][:auditor].to_s == '1'
      new_role_ids << UserRole.id_for(:initiator) if vp_role_params[:user_roles][:initiator].present? and
          vp_role_params[:user_roles][:initiator].to_s == '1'
    end
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    new_role_ids.uniq!
    self.roles_to_add_vp = new_role_ids - existing_role_ids
    self.roles_to_remove_vp = existing_role_ids - new_role_ids
    ###############################################################


    ###### setting up the invoicing roles #########################
    self.fc_purpose_id = Purpose.id_for(:invoice)

    existing_role_ids = being_updated_user.role_mapping.invoicing.map(&:user_role_id)
    new_role_ids = fc_role_params[:user_role_id]
    if new_role_ids.blank? and fc_role_params[:user_roles].present?
      new_role_ids = []
      new_role_ids << UserRole.id_for(:admin) if fc_role_params[:user_roles][:admin].present? and
          fc_role_params[:user_roles][:admin].to_s == '1'
      new_role_ids << UserRole.id_for(:auditor) if fc_role_params[:user_roles][:auditor].present? and
          fc_role_params[:user_roles][:auditor].to_s == '1'
      new_role_ids << UserRole.id_for(:initiator) if fc_role_params[:user_roles][:initiator].present? and
          fc_role_params[:user_roles][:initiator].to_s == '1'
    end
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    new_role_ids.uniq!
    self.roles_to_add_fc = new_role_ids - existing_role_ids
    self.roles_to_remove_fc = existing_role_ids - new_role_ids
    ################################################################
  end

  def process
    
    ###### setting the new roles for Expense Management first ##########
    if roles_to_add_em.present? or roles_to_remove_em.present?
      create = []
      roles_to_add_em.each do |role_id|
        unless role_id.blank?
          create << {user_id: being_updated_user.id, user_role_id: role_id,
                     purpose_id: em_purpose_id}
        end
      end
      UserRoleMapping.create(create) if create.present?
      being_updated_user.role_mapping.expense_management.role(roles_to_remove_em).destroy_all if roles_to_remove_em.present?
    end
    ####################################################################

    ###### setting the new roles for Vendor Payments #############
    if roles_to_add_vp.present? or roles_to_remove_vp.present?
      create = []
      roles_to_add_vp.each do |role_id|
        unless role_id.blank?
          create << {user_id: being_updated_user.id, user_role_id: role_id,
                    purpose_id: vp_purpose_id}
        end
      end
      UserRoleMapping.create(create) if create.present?
      being_updated_user.role_mapping.vendor_payments.role(roles_to_remove_vp).destroy_all if roles_to_remove_vp.present?
    end
    #####################################################################

    ###### setting the new roles for Finly Collect Invoicing #############
    if roles_to_add_fc.present? or roles_to_remove_fc.present?
      create = []
      roles_to_add_fc.each do |role_id|
        unless role_id.blank?
          create << {user_id: being_updated_user.id, user_role_id: role_id,
                     purpose_id: fc_purpose_id}
        end
      end
      # todo - waiting for frontend to add these options in the admin panel
      # UserRoleMapping.create(create) if create.present?
      # being_updated_user.role_mapping.invoicing.role(roles_to_remove_fc).destroy_all if roles_to_remove_fc.present?
    end
    #####################################################################

  end

  def post_process
    add_message :success, 'Role updated!'
  end

end