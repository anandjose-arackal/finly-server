class PolicyPolicy < ApplicationPolicy

  def initialize(user, policy)
    @user = user
    @policy = policy
    @policy_user_service = PolicyUserService.new(@policy)
  end

  def create?
    check_admin_view
  end

  def index?
    # i.e. it's only visible in the admin or personal view
    check_admin_view or check_policy_admin
  end

  def show?
    check_policy_user
  end

  def invitable_users?
    check_policy_admin or check_admin_view
  end

  def add_users?
    check_policy_admin or check_admin_view
  end

  def remove_users?
    check_policy_admin or check_admin_view
  end

  def update_user_configuration?
    check_policy_admin or check_admin_view
  end

  def add_rule?
    check_policy_admin
  end

  def remove_rule?
    check_policy_admin
  end

  private

  # checks if the current user is the policy admin
  def check_policy_admin
    # if it's a company admin, he can do whatever he wants
    return true if check_admin_view
    # else it has to be a policy admin
    return true if @user.policy_admin?
    false
  end

  # checks if current user is part of this policy
  def check_policy_user
    @policy.user_mapping.each do |mapping|
      if mapping.user.id == @user.id
        return true
      end
    end
    false
  end

end