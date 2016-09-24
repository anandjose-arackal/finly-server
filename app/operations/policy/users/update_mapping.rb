# action to update the user's team in the particular policy
# params:
# policy_id: id of the policy that is being edited
# user_id: id of the user that is being updated
# view: the view of the user updating the policy - admin or policy_admin
# default: the default mapping attributes for this policy
#       manager_id: default manager for this policy
#       finance_manager_id: default finance manager for this policy
#       approves_to_id: default approves to for this policy, nil if not a manager
#       approves_finance_to: default approves_finance_to for this policy, nil if not a finance manager
#       team_mapping_id: id of the team mapping that the user is mapped to
# conditional_manager:
#       amount: value of the amount above which the mapping is activated
#       currency_id: currency of the amount
#       manager_id: id of the conditional manager
#       team_mapping_id: id of the conditional manager mapping. Leave blank if it's being created anew
# conditional_finance_manager:
#       amount: value of the amount above which the mapping is activated
#       currency_id: currency of the amount
#       finance_manager_id: id of the conditional finance manager
#       team_mapping_id: id of the conditional finance manager mapping. Leave blank if it's being created anew
# conditional_approves_to:
#       amount: value of the amount above which the mapping is activated
#       currency_id: currency of the amount
#       approves_to_id: id of the conditional manager
#       team_mapping_id: id of the conditional approves to mapping. Leave blank if it's being created anew
# conditional_approves_finance_to:
#       amount: value of the amount above which the mapping is activated
#       currency_id: currency of the amount
#       approves_finance_to_id: id of the conditional finance manager
#       team_mapping_id: id of the conditional approves finance to mapping. Leave blank if it's being created anew

class Policy::Users::UpdateMapping < Policy::Base

  attr_accessor :user_manager_mappings, :being_updated_user, :policy, :policy_params,
                :admin

  def authorized_user_types
    [:admin, :policy_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed"
    end
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id])
    self.policy_params = params.require(:policy).permit!
    self.being_updated_user = policy.users.find_by(id: policy_params[:user_id])
    set_update_parameters
  end

  def authorize
    unless policy and being_updated_user
      raise_unauthorized_exception
    end
  end

  def validate

  end

  # if the user is being added as policy admin, record that change here
  def pre_process
    if params[:policy][:admin] == "1"
      self.admin = true
    else
      self.admin = false
    end
  end

  def process
    result = Policy::Mappings::Set.new(user, params).run
    if result.success?
      messages[:success] = "User mapping updated"
    else
      messages[:error] = result.messages[:error]
    end
  end

  # making the user a policy admin here
  def post_process
    user_policy_mapping = being_updated_user.policy_user_mappings.with_policy(policy.id).first rescue nil
    user_policy_mapping.update_attributes(admin: admin)
  end

  def success
    Policy::Base::PolicyPresenter.new(user, {policy: policy})
  end

  private

  def set_update_parameters
    self.user_manager_mappings = {}
    user_manager_mappings[:default] = {}
    user_manager_mappings[:default][:mapping] = policy_params[:default].except(:mapping_id)
    user_manager_mappings[:default][:mapping_id] = policy_params[:default][:mapping_id]
    if policy_params[:conditional_manager] and policy_params[:conditional_manager][:greater_than_amount_attributes][:value].present?
      user_manager_mappings[:conditional_manager] = {}
      user_manager_mappings[:conditional_manager][:mapping] = policy_params[:conditional_manager].except(:mapping_id)
      user_manager_mappings[:conditional_manager][:mapping_id] = policy_params[:conditional_manager][:mapping_id]
    end
    if policy_params[:conditional_finance_manager] and policy_params[:conditional_finance_manager][:greater_than_amount_attributes][:value].present?
      user_manager_mappings[:conditional_finance_manager] = {}
      user_manager_mappings[:conditional_finance_manager][:mapping] = policy_params[:conditional_finance_manager].except(:mapping_id)
      user_manager_mappings[:conditional_finance_manager][:mapping_id] = policy_params[:conditional_finance_manager][:mapping_id]
    end
    if policy_params[:conditional_approves_to] and policy_params[:conditional_approves_to][:greater_than_amount_attributes][:value].present?
      user_manager_mappings[:conditional_approves_to] = {}
      user_manager_mappings[:conditional_approves_to][:mapping] = policy_params[:conditional_approves_to].except(:mapping_id)
      user_manager_mappings[:conditional_approves_to][:mapping_id] = policy_params[:conditional_approves_to][:mapping_id]
    end
    if policy_params[:conditional_approves_finance_to] and policy_params[:conditional_approves_finance_to][:greater_than_amount_attributes][:value].present?
      user_manager_mappings[:conditional_approves_finance_to] = {}
      user_manager_mappings[:conditional_approves_finance_to][:mapping] = policy_params[:conditional_approves_finance_to].except(:mapping_id)
      user_manager_mappings[:conditional_approves_finance_to][:mapping_id] = policy_params[:conditional_approves_finance_to][:mapping_id]
    end
    params[:user_manager_mapping] = user_manager_mappings
    params[:user_id] = policy_params[:user_id]
  end

end