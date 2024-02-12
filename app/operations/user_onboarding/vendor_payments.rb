# This would bulk assign users to multiple policies and selected roles
# 

class UserOnboarding::VendorPayments < UserOnboarding::Base
  attr_accessor :policy_ids, :policies, :user_role_ids, :user_ids, :assignable_roles, :unassignable_roles,
                :urm_columns, :urm_values, :pur_columns, :pur_values, :urm_unassignable_roles,
                :urm_user_role_ids, :pur_user_role_ids,
                :pur_unassignable_roles

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.policy_ids.blank?
      add_message(:error, "No Policy found for this company.")
      return
    end

    if self.pur_user_role_ids.blank?
      add_message(:error, "User Role does not exist for this company.")
      return
    end

    if self.user_ids.blank?
      add_message(:error, "No Users found for this company.")
      return
    end

  end

  def pre_process
    # in vendor payments, user roles are defined in one table
    # policy_user_roles
    # 
    flow(pre_process_pur, true)
    self.pur_unassignable_roles = self.unassignable_roles
    self.pur_columns, self.pur_values = setup_pur(assignable_roles)

    flow(pre_process_urm, false)
    self.urm_unassignable_roles = self.unassignable_roles
    self.urm_columns, self.urm_values = setup_urm(assignable_roles)

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
    if self.pur_unassignable_roles.present?
      fields = [:policy, :user, :user_role]
      # params[:unassignable_roles] = self.unassignable_roles.map {|role| fields.zip(role).to_h }

      params[:unassignable_roles] = self.pur_unassignable_roles.map do |role|
        policy = policies.find {|policy| policy if policy.id == role.first}
        user = users.find {|u| u if u.id == role.second}
        roles = UserRole::VALUES.invert[role.third]
        pur = [{id: policy&.id, name: policy&.name}, {id: user&.id, email: user&.email}, {id: role.last, name: roles.to_s}]
        fields.zip(pur).to_h
      end
    end

    return false if has_errors?

  end

  def process
    # Bulk insert into table, 
    # much faster  
    exec_statement(pur_columns, pur_values, :policy_user_roles) if pur_user_role_ids.present?
    exec_statement(urm_columns, urm_values, :user_role_mappings) if urm_unassignable_roles.blank?

  end

  def post_process
    add_message :success, "Selected user(s) were successfully invited and configured."
  end

  def success
    UserOnboarding::VendorPayments::IndexPresenter.new(user, params, messages)
  end

  def failure
    UserOnboarding::VendorPayments::FailurePresenter.new(user, params, messages)
  end

  class UserOnboarding::VendorPayments::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :unassignable_roles

    def init
      self.unassignable_roles = params[:unassignable_roles]
    end
  end

  class UserOnboarding::VendorPayments::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :unassignable_roles

    def init
      self.unassignable_roles = params[:unassignable_roles]
    end
  end

  private

  def flow(preprocessor, check = false)
    # we are using check since for all vp user, we got create entry in urm and make them initiator, otherwise they can;t login
    # check tells us, to skip error if already made employee but going to give him some other role
    # 
    self.assignable_roles, self.unassignable_roles = preprocessor

    if check and assignable_roles.blank?
      add_message :error, "Request cannot be processed. Perhaps, selected users are already assigned to the chosen policies with the specified roles."
      return
    end
  end


end