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

require "#{Rails.root}/lib/operations/user/team/mappings/update"

class Policy::Users::UpdateConfiguration < Policy::Base

  attr_accessor :default, :conditional_manager_mapping, :conditional_finance_mapping,
                :conditional_approves_to_mapping, :conditional_approves_finance_to_mapping

  attr_accessor :being_updated_user

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed"
    end
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id])
    self.being_updated_user = policy.users.find_by(id: params[:user_id])
    add_user_and_policy_to_params
  end

  def validate

  end

  def authorize
    unless policy and being_updated_user
      raise_unauthorized_exception
    end
    self.default = policy.user_team_mapping.find_by(id: params[:default][:team_mapping_id])
    self.conditional_manager_mapping = policy.user_team_mapping.find_by(id: params[:conditional_manager][:team_mapping_id]) if params[:conditional_manager]
    self.conditional_finance_mapping = policy.user_team_mapping.find_by(id: params[:conditional_finance_manager][:team_mapping_id]) if params[:conditional_finance_manager]
    self.conditional_approves_to_mapping = policy.user_team_mapping.find_by(id: params[:conditional_approves_to][:team_mapping_id]) if params[:conditional_approves_to]
    self.conditional_approves_finance_to_mapping = policy.user_team_mapping.find_by(id: params[:conditional_approves_finance_to][:team_mapping_id]) if params[:conditional_approves_finance_to]
  end

  def process
    if default
      self.default = User::Team::Mappings::Update.new(user, params[:default]).run
    else
      self.default = User::Team::Mappings::Create.new(user, params[:default]).run
    end
    if conditional_manager_mapping
      self.conditional_manager_mapping = User::Team::Mappings::Update.new(user, params[:conditional_manager]).run
    elsif params[:conditional_manager]
      self.conditional_manager_mapping = User::Team::Mappings::Create.new(user, params[:conditional_manager]).run
    end
    if conditional_finance_mapping
      self.conditional_finance_mapping = User::Team::Mappings::Update.new(user, params[:conditional_finance_manager]).run
    elsif params[:conditional_finance_manager]
      self.conditional_finance_mapping = User::Team::Mappings::Create.new(user, params[:conditional_finance_manager]).run
    end
    if conditional_approves_to_mapping
      self.conditional_approves_to_mapping = User::Team::Mappings::Update.new(user, params[:conditional_approves_to]).run
    elsif params[:conditional_approves_to]
      self.conditional_approves_to_mapping = User::Team::Mappings::Create.new(user, params[:conditional_approves_to]).run
    end
    if conditional_approves_finance_to_mapping
      self.conditional_approves_finance_to_mapping = User::Team::Mapping::Update.new(user, params[:conditional_approves_finance_to]).run
    elsif params[:conditional_approves_finance_to]
      self.conditional_approves_finance_to_mapping = User::Team::Mapping::Create.new(user, params[:conditional_approves_finance_to]).run
    end
  end

  def post_process

  end

  private

  def add_user_and_policy_to_params
    if params[:default]
      params[:default][:user_id] = being_updated_user.id
      params[:default][:policy_id] = policy.id
    end
    if params[:conditional_manager]
      params[:conditional_manager][:user_id] = being_updated_user.id
      params[:conditional_manager][:policy_id] = policy.id
    end
    if params[:conditional_finance_manager]
      params[:conditional_finance_manager][:user_id] = being_updated_user.id
      params[:conditional_finance_manager][:policy_id] = policy.id
    end
    if params[:conditional_approves_to]
      params[:conditional_approves_to][:user_id] = being_updated_user.id
      params[:conditional_approves_to][:policy_id] = policy.id
    end
    if params[:conditional_approves_finance_to]
      params[:conditional_approves_finance_to][:user_id] = being_updated_user.id
      params[:conditional_approves_finance_to][:policy_id] = policy.id
    end
  end

end