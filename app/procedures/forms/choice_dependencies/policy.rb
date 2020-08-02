class Forms::ChoiceDependencies::Policy < ApplicationPolicy

  def index?
    @user.admin?
  end

  def create?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def show?
    @user.admin?
  end

  def destroy?
    @user.admin?
  end

  def enable?
    @user.admin?
  end

  def disable?
    @user.admin?
  end

end