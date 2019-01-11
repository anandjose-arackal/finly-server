class User::Team::GetManagers < User::Team::Base
  attr_accessor :role_id, :company, :team, :team_managers, :team_finance_managers, :team_policies, :team_admins, :for_user

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] = 'User or params not found'
    end
  end

  def init
    # the role under which the user is inviting employees
    self.role_id = params[:view].present? ? UserRole::VALUES[params[:view].to_sym] : UserRole.id_for(:employee)
    self.company = user.company
    for_user_id = (params[:for_user_id] or params[:id] or params[:user_id])
    self.for_user = User::Team::Index.(user, params).with_id(for_user_id).first rescue nil if for_user_id.present?
  end

  def process
    self.team = User::Team::Index.(user, params)
    self.team_admins = []
    if role_id == UserRole.manager_id
      team_managers_ids = team.signed_up.with_roles.only_managers.pluck(:id)
      team_managers_ids << user.id
      self.team_managers = User.with_id(team_managers_ids)
      self.team_policies = user.admin_policies
    else
      self.team_managers = company.managers.signed_up
    end
    if role_id == UserRole.finance_manager_id
      team_finance_managers_ids = team.signed_up.with_roles.only_finance_managers.pluck(:id)
      team_finance_managers_ids << user.id
      self.team_finance_managers = User.with_id(team_finance_managers_ids)
      self.team_policies = user.admin_policies
    else
      self.team_finance_managers = company.finance_managers.signed_up
    end
    if role_id == UserRole.admin_id
      self.team_admins = company.admins.signed_up
      self.team_policies = company.policies.non_default
    end
  end

  def success
    User::Team::GetManagersPresenter.new(user, {for_user: for_user, team: team, team_managers: team_managers,
                                                team_finance_managers: team_finance_managers,
                                                team_policies: team_policies,
                                                team_admins: team_admins}, messages)
  end

  class User::Team::GetManagersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :actions, :team, :team_managers, :team_finance_managers, :team_policies, :team_admins, :for_user

    def init
      self.for_user = params[:for_user]
      self.team = params[:team]
      self.team_admins = params[:team_admins] || []
      self.team_managers = params[:team_managers]
      self.team_finance_managers = params[:team_finance_managers]
      self.team_policies = params[:team_policies]
      if for_user.present?
        self.team_managers = self.team_managers.without_id(for_user.id) rescue nil if self.team_managers.present?
        self.team_finance_managers = self.team_finance_managers.without_id(for_user.id) rescue nil if self.team_finance_managers.present?
      end
    end
  end

end
