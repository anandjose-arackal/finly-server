class UserPolicy < ApplicationPolicy

  def index?
    check_admin_view
  end

  def user_details?
    check_admin_view
  end

  def update_team?
    check_admin_view
  end

  def update_password?
    check_personal_view
  end

  def profile
    check_personal_view
  end
end