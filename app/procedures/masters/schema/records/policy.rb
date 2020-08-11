class Masters::Schema::Records::Policy < ApplicationPolicy

  def create?
    user.admin?("vp")
  end

  def update?
    user.admin?("vp")
  end

  def show?
    user.admin?("vp")
  end

  def index?
    user.admin?("vp")
  end

  def destroy?
    user.admin?("vp")
  end

  def import?
    true
  end

end