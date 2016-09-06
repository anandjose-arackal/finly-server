class Policy::InvitableUsers < Policy::Base

  attr_accessor :invitable_users

  class Policy::InvitableUsers::InvitableUsersPresenter < Policy::Base::BasePresenter

    attr_accessor :invitable_users

    has_scope :filter_email
    has_scope :filter_name

    def initialize(user, params)
      self.invitable_users = apply_scopes(params[:invitable_users])
    end

    def users_with_manager_email
      invitable_users.each do |user|
        manager = User::Team::Approver.new(user, type: :manager).run
        manager_email = nil
        manager_email = manager.email if manager.present?
        users << {user: user, manager: manager_email}
      end
      users
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    id = params[:policy_id] || params[:id]
    self.policy = Policy::List.(user, view: params[:view]).find_by(id: id)
  end


  def process
    # filtering my manager happens manually, because the particular manager's team needs to be filtered out
    self.invitable_users = policy.company.users.without_id(policy.users.pluck(:id)).sort_by_name
    manager_id = params[:filter_manager_id]
    if manager_id.present?
      manager = policy.company.users.find_by_id(manager_id)
      manager_team = User::Team::Index.(manager, role_id: UserRole.manager_id)
      if manager_team.present?
        self.invitable_users = manager_team
      end
    end
  end

  def retrieve
    if is_success?
      Policy::InvitableUsers::InvitableUsersPresenter.new(user, {invitable_users: invitable_users})
    else
      return false
    end
  end


end