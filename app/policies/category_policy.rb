class CategoryPolicy < ApplicationPolicy

  def initialize(user, category)
    @user = user
    @category = category
  end

  def create?
    check_admin_view
  end

  def destroy?
    check_admin_view
  end
end