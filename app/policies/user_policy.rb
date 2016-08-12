class UserPolicy < ApplicationPolicy

  def initialize(user, record)
    @user = user
  end

  def index?
    # i.e. everyone other than employees can access the Users listing
    if check_personal_view
      return false
    end
    true
  end

  def user_details?
    # i.e. everyone other than employees can access the User details
    if check_personal_view
      return false
    end
    true
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