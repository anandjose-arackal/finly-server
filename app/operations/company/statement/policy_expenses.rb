class Company::PolicyExpenses < Company::Statement::Base


  # company admin or policy admin can access this operation
  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    if user.company_admin? and view.policy_admin?

    end
  end


end