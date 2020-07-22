class Admin::Masters::Macros::Policy < ApplicationPolicy

  def create?
    true
  end

  def show?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

end