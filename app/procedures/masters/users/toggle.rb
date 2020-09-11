class Masters::Users::Toggle < ApplicationToggle

  def maximum_users
    feature_value 'permission/users#count', 0
  end

end