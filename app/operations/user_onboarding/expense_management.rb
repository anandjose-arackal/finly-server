# This would bulk assign users to multiple policies and selected roles
# 

class UserOnboarding::ExpenseManagement < UserOnboarding::Base
  attr_accessor :policy_ids, :policies, :user_role_ids, :user_ids, :assignable_roles, :unassignable_roles,
                :urm_columns, :urm_values, :pur_columns, :pur_values,
                :urm_unassignable_roles, :pur_unassignable_roles,
                :urm_user_role_ids, :pur_user_role_ids,
                :pum_unassignable_roles, :pum_columns, :pum_values

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.bulk_assign[:policy_ids].present? and self.policy_ids.blank?
      add_message(:error, "No Policy found for this company.")
      return
    end

    if self.urm_user_role_ids.blank? and self.pur_user_role_ids.blank?
      add_message(:error, "User Role does not exist for this company.")
      return
    end

    if self.user_ids.blank?
      add_message(:error, "No Users found for this company.")
      return
    end

  end

  def pre_process
    # in expense mangement, user roles are defined in two tables
    # user_role_mappings 
    # and
    # policy_user_roles
    # 

    flow(pre_process_pum)
    self.pum_unassignable_roles = self.unassignable_roles
    self.pum_columns, self.pum_values = setup_pum(assignable_roles)

    return false if has_errors?

    if urm_user_role_ids.present?
      flow(pre_process_urm, check = false)
      self.urm_unassignable_roles = self.unassignable_roles
      self.urm_columns, self.urm_values = setup_urm(assignable_roles)

      flow(pre_process_pur)
      self.pur_unassignable_roles = self.unassignable_roles
      self.pur_columns, self.pur_values = setup_pur(assignable_roles)
    end

    # builds this format for FE to show unassignable roles
    # 
    # "unassignable_roles":[
    #   {
    #      "policy":{
    #         "id":1,
    #         "name":"Company (Default)"
    #      },
    #      "user":{
    #         "id":25,
    #         "email":"borah@borah.caves"
    #      },
    #      "user_role":{
    #         "id":10,
    #         "name":"purchase_request_initiator"
    #      }
    #   }
    # ]
    # 
    if self.unassignable_roles.present?
      fields = [:policy, :user, :user_role]
      self.unassignable_roles = self.pur_unassignable_roles.to_a
      # params[:unassignable_roles] = self.unassignable_roles.map {|role| fields.zip(role).to_h }

      params[:unassignable_roles] = self.unassignable_roles.map do |role|
        policy = policies.find {|policy| policy if policy.id == role.first}
        user = users.find {|u| u if u.id == role.second}
        roles = UserRole::VALUES.invert[role.third]
        pur = [{id: policy.id, name: policy.name}, {id: user.id, email: user.email}, {id: role.last, name: roles.to_s}]
        fields.zip(pur).to_h
      end
    end

    return false if has_errors?

  end

  def process
    # Bulk insert into table, 
    # much faster  
    exec_statement(pum_columns, pum_values, :policy_user_mappings) if urm_user_role_ids.present?
    exec_statement(urm_columns, urm_values, :user_role_mappings) if urm_user_role_ids.present?

    exec_statement(pur_columns, pur_values, :policy_user_roles) if urm_user_role_ids.present?

  end

  def post_process
    add_message :success, "Selected user(s) were successfully invited and configured."
  end

  def success
    UserOnboarding::ExpenseManagement::IndexPresenter.new(user, params, messages)
  end

  def failure
    UserOnboarding::ExpenseManagement::FailurePresenter.new(user, params, messages)
  end

  class UserOnboarding::ExpenseManagement::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :unassignable_roles

    def init
      self.unassignable_roles = params[:unassignable_roles]
    end
  end

  class UserOnboarding::ExpenseManagement::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :unassignable_roles

    def init
      self.unassignable_roles = params[:unassignable_roles]
    end
  end

  private

  def flow(preprocessor, check = true)
    self.assignable_roles, self.unassignable_roles = preprocessor

    if check && assignable_roles.blank?
      add_message :error, "Request cannot be processed. Perhaps, selected users are already assigned to the chosen policies with the specified roles."
      return
    end
  end


end