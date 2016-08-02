class PolicyPolicy < ApplicationPolicy

  def initialize(user, policy)
    @user = user
    @policy = policy
    @policy_user_service = PolicyUserService.new(@policy)
  end

  def create?
    if @user.admin? and check_admin_view
      return true
    end
    false
  end

  def index?

  end

  def show?
    check_policy_user
  end

  def invitable_users?
    check_policy_admin
  end

  def add_users?
    check_policy_admin
  end

  def remove_users?
    check_policy_admin
  end

  def update_user_configuration?
    check_policy_admin
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
    @policy.user_mapping.admin.each do |admin_mapping|
      if admin_mapping.user.id == @user.id and check_admin_view
        return true
      end
    end
    false
  end

  # checks if current user is part of this policy
  def check_policy_user
    @policy.user_mappping.each do |mapping|
      if mapping.user.id == @user.id
        return true
      end
    end
    false
  end

end