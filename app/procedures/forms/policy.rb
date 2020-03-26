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

end