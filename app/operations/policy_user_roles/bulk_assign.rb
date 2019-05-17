# This would bulk assign users to multiple policies and selected roles
# 

class PolicyUserRoles::BulkAssign < PolicyUserRoles::Base
  attr_accessor :policy_ids, :user_role_ids, :user_ids, :assignable, :unassignable_roles

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

    if params[:bulk_assign][:user_ids].blank?
      add_message(:error, "No Users selected.")
      return
    end

  end

  def init
    bulk_assign = params[:bulk_assign]
    self.policy_ids = user.company.policies.with_id(bulk_assign[:policy_ids]).pluck(:id) rescue nil
    self.user_role_ids = ( UserRole::VP_ROLES.values & bulk_assign[:user_role_ids] ) rescue nil
    self.user_ids = user.company.users.with_id(bulk_assign[:user_ids]).pluck(:id) rescue nil
  end

  def validate
    if self.policy_ids.blank?
      add_message(:error, "No Policy found for this company.")
      return
    end

    if self.user_role_ids.blank?
      add_message(:error, "User Role does not exist for this company.")
      return
    end

    if self.user_ids.blank?
      add_message(:error, "No Users found for this company.")
      return
    end

  end

  def pre_process
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
    new_roles = self.policy_ids.product(self.user_ids, self.user_role_ids)

    # -> assignable roles
    # now we check for the new_roles to be assigned, comparing against the result from all_roles.
    # this check answers the question, do we have anything similar in the table?
    # thats it.
    assignable_roles = new_roles - all_roles

    self.unassignable_roles = new_roles & all_roles

    if assignable_roles.blank?
      add_message :error, "Request cannot be processed. Perhaps, selected users are already assigned to the chosen policies with the specified roles."
      return
    end

    add_date = DateTime.now.strftime('%Y-%m-%d %l:%M:%S')

    # RETURNS "(1,2,3, '2019-05-11 17:40:58', '2019-05-11 17:40:58'), (4,5,6, '2019-05-11 17:40:58', '2019-05-11 17:40:58), (...), ...."
    self.assignable = assignable_roles.collect { |p_id, u_id, r_id| "(#{p_id}, #{u_id}, #{r_id}, '#{add_date}', '#{add_date}')" }.join(",")
  end

  def process
    # Bulk insert into table, 
    # much faster  
    begin
      sql = "INSERT INTO policy_user_roles (policy_id, user_id, user_role_id, created_at, updated_at) VALUES #{self.assignable}"
      ActiveRecord::Base.connection.execute(sql)
    rescue => e
      add_message :error, "Error while assigning multiple users to policies. Please try again later."
      Rails.logger.fatal "Error occurred while bulk assigning - #{e.inspect}"
      return
    end

  end

  def post_process
    add_message :success, "Multiple users were bulk assigned to #{self.policy_ids.count} policies."
  end

  def success
    PolicyUserRoles::BulkAssign::IndexPresenter.new(user, params, messages)
  end

  def failure
    fields = [:policy_id, :user_id, :user_role_id]
    params[:unassignable_roles] = self.unassignable_roles.map {|role| fields.zip(role).to_h }
    PolicyUserRoles::BulkAssign::FailurePresenter.new(user, params, messages)
  end

  class PolicyUserRoles::BulkAssign::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def init

    end
  end

  class PolicyUserRoles::BulkAssign::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :self.unassignable_roles

    def init
      self.unassignable_roles = params[:unassignable_roles]
    end
  end

end
