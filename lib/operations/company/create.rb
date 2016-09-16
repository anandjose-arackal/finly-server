class Company::Create < Company::Base

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] = "No user or params passed."
    end
  end

  def init

  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(current_user.email)
      raise_unauthorized_exception
    end
  end

end