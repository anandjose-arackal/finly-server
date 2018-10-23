module OperationValidations

  def user_present?
    if user.blank?
      add_message :error, 'User not found'
      return false
    end
    true
  end

  def params_present?
    if params&.nil?
      add_message :error, 'Error loading request'
      return false
    end
    true
  end

end