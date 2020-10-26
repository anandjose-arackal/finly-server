class Forms::Policy < ApplicationPolicy

  def create?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def show?
    @user.admin?
  end

  def config?
    true
  end

  def index?
    @user.admin?
  end

  def entity_config?
    @user.admin?
  end

end