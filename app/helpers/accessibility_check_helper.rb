module AccessibilityCheckHelper

  # checks if a user is logged in
  def logged_in?
    !current_user.nil?
  end

  # checks if the user passed as argument is current user
  def current_user?(user)
    user == current_user
  end

  # def validate_logged_in_user
  #   unless logged_in?
  #     flash[:danger] = 'You need to log in first!'
  #     redirect_to new_user_session_path
  #   end
  # end

end