class User::Team::GetManagers < User::Team::Base

  attr_accessor :role_id, :company, :team, :team_managers, :team_finance_managers, :team_policies, :team_admins

  class User::Team::GetManagersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :actions, :team, :team_managers, :team_finance_managers, :team_policies, :team_admins

    def init
      self.team = params[:team]
      self.team_managers = params[:team_managers]
      self.team_finance_managers = params[:team_finance_managers]
      self.team_policies = user.admin_policies
      self.team_admins = params[:team_admins]
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] = "User or params not found."
    end
  end

  def init
    # the role under which the user is inviting employees
    self.role_id = UserRole::VALUES[params[:view].to_sym]
    self.company = user.company
  end

  def process
    self.team = User::Team::Index.new(user, params).run
    if role_id == UserRole.manager_id
      self.team_managers = team.with_roles.only_managers
      self.team_managers << user
      self.team_policies = user.admin_policies
    else
      self.team_managers = company.managers
    end
    if role_id == UserRole.finance_manager_id
      self.team_finance_managers = team.with_roles.only_finance_managers
      self.team_finance_managers << user
      self.team_policies = user.admin_policies
    else
      self.team_finance_managers = company.finance_managers
    end
    if role_id == UserRole.admin_id
      self.team_admins = company.admins
      self.team_policies = company.policies
    end
  end

  def success
    User::Team::GetManagersPresenter.new(user, {team: team, team_managers: team_managers,
                                                team_finance_managers: team_finance_managers,
                                                team_policies: team_policies,
                                                team_admins: team_admins}, messages)
  end

end
