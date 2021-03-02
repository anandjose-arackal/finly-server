class Companies::Policy < ApplicationPolicy

  # TODO: update this to check for org admin role

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def disable?
    update? && record&.active?
  end

end