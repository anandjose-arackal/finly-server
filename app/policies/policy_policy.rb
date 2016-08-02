class PolicyPolicy < ApplicationPolicy

  def initialize(user, policy)
    @user = user
    @policy = policy
    @policy_user_service = PolicyUserService.new(@policy)
  end

  def create?

  end

  def index?

  end

  def show?

  end

  def invitable_users?

  end

  def add_users?

  end

  def remove_users?

  end

  def update_user_configuration?

  end

  def add_rule?

  end

  def remove_rule?

  end

end