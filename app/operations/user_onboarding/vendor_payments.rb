# This would bulk assign users to multiple policies and selected roles
# 

class UserOnboarding::VendorPayments < UserOnboarding::Base
  attr_accessor :policy_ids, :policies, :user_role_ids, :user_ids, :assignable_roles, :unassignable_roles,
                :urm_columns, :urm_values, :pur_columns, :pur_values,
                :urm_user_role_ids, :pur_user_role_ids,
                :pur_unassignable_roles

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
    flow(pre_process_pur)
    self.pur_unassignable_roles = self.unassignable_roles
    self.pur_columns, self.pur_values = setup_pur(assignable_roles)

    return false if has_errors?

  end

  def process
    # Bulk insert into table, 
    # much faster  
    exec_statement(pur_columns, pur_values, :policy_user_roles) if pur_user_role_ids.present?

    if self.unassignable_roles.present?
      fields = [:policy, :user, :user_role]
      # params[:unassignable_roles] = self.unassignable_roles.map {|role| fields.zip(role).to_h }

      params[:unassignable_roles] = self.unassignable_roles.map do |role| 
        policy = policies.find {|policy| policy if policy.id == role.first}
        user = users.find {|u| u if u.id == role.second}
        roles = UserRole::VALUES.invert[role.third]
        pur = [{id: policy.id, name:policy.name}, {id: user.id, email: user.email}, {id: role.last, name: roles.to_s}]
        fields.zip(pur).to_h 
      end
    end
  end

  def post_process
    add_message :success, "Multiple users were successfully configured."
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

  def flow(preprocessor)
    self.assignable_roles, self.unassignable_roles = preprocessor

    if assignable_roles.blank?
      add_message :error, "Request cannot be processed. Perhaps, selected users are already assigned to the chosen policies with the specified roles."
      return
    end
  end


end