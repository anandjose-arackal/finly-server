class Appsmith::UsersController < BaseControllers::AppsmithBase

  def reset_password
    endpoint Appsmith::Companies::ResetPassword
  end
end
