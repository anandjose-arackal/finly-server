class UserToggle < ApplicationToggle

  def maximum_users
    feature_value 'permission/users#count', 0
  end

end