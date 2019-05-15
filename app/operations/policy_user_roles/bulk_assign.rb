# This would bulk assign users to multiple policies and selected roles
# 

class PolicyUserRoles::BulkAssign < PolicyUserRoles::Base
  attr_accessor :policy_ids, :user_role_ids, :user_ids, :assignable

  def pre_validate
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
    add_date = DateTime.now.strftime('%Y-%m-%d %l:%M:%S')

    # RETURNS "(1,2,3, '2019-05-11 17:40:58', '2019-05-11 17:40:58'), (4,5,6, '2019-05-11 17:40:58', '2019-05-11 17:40:58), (...), ...."
    self.assignable = self.policy_ids.product(self.user_ids, self.user_role_ids).collect { |p_id, u_id, r_id| "(#{p_id}, #{u_id}, #{r_id}, '#{add_date}', '#{add_date}')" }.join(",")
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

  class PolicyUserRoles::BulkAssign::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def init

    end
  end
end
