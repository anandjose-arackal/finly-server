# base operation for user onboarding.
# defines all methods and variables.
# em and vp can choose what to use.
# 
class UserOnboarding::Base < BaseOperation
  attr_accessor :policy_ids, :user_role_ids, :user_ids, :assignable_roles, :unassignable_roles, :users, :urm_user_role_ids, :pur_user_role_ids, :bulk_assign, :policies

  def pre_validate
    if params[:bulk_assign].blank?
      add_message :error, "No data was sent for processing."
      return
    end

    if params[:bulk_assign][:policy_ids].blank?
      add_message(:error, "No Policy selected.")
      return
    end

    if params[:bulk_assign][:user_role_ids].blank?
      add_message(:error, "User Role not selected.")
      return
    end

    if params[:bulk_assign][:user_ids].blank? and params[:bulk_assign][:user_emails].blank?
      add_message(:error, "No Users selected.")
      return
    end
  end

  def init
    self.bulk_assign = params[:bulk_assign]
    self.policies = user.company.policies.with_id(bulk_assign[:policy_ids])
    self.policy_ids = self.policies.pluck(:id) rescue nil
    self.urm_user_role_ids = ( UserRole::VALUES_EM.except(:admin, :purchaser, :receiver).values & bulk_assign[:user_role_ids] ) rescue nil
    self.pur_user_role_ids = ( UserRole::VP_ROLES.except(:admin, :policy_admin).values & bulk_assign[:user_role_ids] ) rescue nil
    result = ::UserOnboarding::BuildUsersForImport.(current_user, params)

    unless result.success?
      result.messages.keys.each do |key|
        add_message key, result.messages[key]
      end
      return
    end

    self.users = result.users.to_a
    self.user_ids = self.users.pluck :id
  end

  protected

  def pre_process_urm
    # We will now check if users were already assigned to selected roles
    # since, we need to avoid duplicate records

    # -> find all user_role_mappings for the companies' users
    # we search this table only for the users which definitely belong to the current company
    urm = UserRoleMapping.where(user_id: self.user_ids)

    # -> collect all records
    # from the previous result, we only need to get and search for duplicate records based on combination of 3 columns
    all_roles = urm.pluck(:user_id, :user_role_id, :purpose_id)
    
    # we got to do this shit. some genius decided to build two tables with totally different structure for same functionality and somehow it is a good idea to allow users to login to an app only if they have entry in this table, even though this table has nothing to do with vendor_payments. also sample this, for em this table is used. but travel manager needs to be setup in vendor_payment table. god hates you.
    # 
    if RequestStore.store[:vp_onboarding]
      self.urm_user_role_ids << UserRole.id_for(:initiator)
      purpose_id = Purpose.id_for(:vendor_payments)
    else
      self.urm_user_role_ids << UserRole.id_for(:employee)
      self.urm_user_role_ids.uniq!
      purpose_id = Purpose.id_for(:expense_management)
    end
    # -> create records for searching
    # from the params sent, we create a format compatible to search against the previous result
    new_roles = self.user_ids.product(self.urm_user_role_ids, [purpose_id])

    # -> assignable roles
    # now we check for the new_roles to be assigned, comparing against the result from all_roles.
    # this check answers the question, do we have anything similar in the table?
    # thats it.
    assignable_roles = new_roles - all_roles

    unassignable_roles = new_roles & all_roles

    return assignable_roles, unassignable_roles
  end

  def pre_process_pur
    # We will now check if users were already assigned to selected policies and the roles
    # since, we need to avoid duplicate records

    # -> find all policy_user_roles for the companies' users
    # we search this table only for the users which definitely belong to the current company
    pur = PolicyUserRole.where(user_id: self.user_ids)


    # -> collect all records
    # from the previous result, we only need to get and search for duplicate records based on combination of 3 columns
    all_roles = pur.pluck(:policy_id, :user_id, :user_role_id)

    # -> create records for searching
    # from the params sent, we create a format compatible to search against the previous result
    new_roles = self.policy_ids.product(self.user_ids, self.pur_user_role_ids)

    # -> assignable roles
    # now we check for the new_roles to be assigned, comparing against the result from all_roles.
    # this check answers the question, do we have anything similar in the table?
    # thats it.
    assignable_roles = new_roles - all_roles

    unassignable_roles = new_roles & all_roles

    return assignable_roles, unassignable_roles
  end

  def setup_pur(assignable_roles)
    # setup data points for importing into table
    columns = [:policy_id, :user_id, :user_role_id]
    values = assignable_roles.collect { |p_id, u_id, r_id| [p_id, u_id, r_id] }

    return columns, values
  end

  def setup_urm(assignable_roles)
    # setup data points for importing into table

    # this table controls who can login where.
    if RequestStore.store[:vp_onboarding]
      purpose_id = Purpose.id_for(:vendor_payments)
    else
      purpose_id = Purpose.id_for(:expense_management)
    end
      
    columns = [:user_id, :user_role_id, :purpose_id]
    values = assignable_roles.collect { |u_id, r_id| [u_id, r_id, purpose_id] }
    return columns, values
  end

  def exec_statement(columns, values, klass_name)
    if columns.blank? or values.blank? or klass_name.blank?
      puts "Batch is empty."
      return
    end

    klass = klass_name.to_s.classify.constantize

    begin
      runner columns, values, klass
      true
    rescue => e
      add_message :error, "Error while configuring multiple users. Please contact Finly Customer Support if problem persists."
      puts "Import Signature - #{self.class.name}"
      puts "Error importing the bulk. Reason #{e.message}"
      Rails.logger.fatal "Error occurred while bulk assigning - #{e.inspect}"
      false
    end
  end

  def runner(columns, values, klass)
    klass.import columns, values
  end

end