class Policy::InvitableUsers < Policy::Base

  attr_accessor :invitable_users

  class Policy::InvitableUsers::InvitableUsersPresenter < Policy::Base::BasePresenter

    attr_accessor :invitable_users, :policy

    has_scope :filter_email
    has_scope :filter_name

    def init
      self.invitable_users = apply_scopes(params[:invitable_users], params)
      self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id] || params[:id])
    end

    def users_with_manager_email
      users = []
      invitable_users.each do |user|
        approver_op = User::Team::Approver.new(user, {type: :manager, policy_id: policy.id})
        manager = approver_op.run
        manager_email = nil
        manager_email = manager.email if manager.is_a?(User)
        users << {user: user, manager: manager_email}
      end
      users
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    id = params[:policy_id] || params[:id]
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: id)
  end


  def process
    # filtering by manager happens manually, because the particular manager's team needs to be filtered out
    self.invitable_users = policy.company.users.signed_up.without_id(policy.users.pluck(:id)).sort_by_name
    manager_id = params[:filter_manager_id]
    if manager_id.present?
      manager = policy.company.users.find_by_id(manager_id)
      manager_team = User::Team::Index.(manager, role_id: UserRole.manager_id)
      if manager_team.present?
        self.invitable_users = manager_team.signed_up
      end
    end
  end

  def success
    params[:invitable_users] = invitable_users
    Policy::InvitableUsers::InvitableUsersPresenter.new(user, params, messages)
  end


end