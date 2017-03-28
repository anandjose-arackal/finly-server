class ExpenseTypes::Update < ExpenseTypes::Base

  attr_accessor :configurable_object, :company

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    if params[:configurable_type] == 'policy' && user.policy_admin?
      self.configurable_object = company.policies.find_from_id(params[:policy_id])
    elsif params[:configurable_type] == 'company' && user.company_admin?
      self.configurable_object = company
    end
  end

  def authorize
    if configurable_object.blank?
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process

  end
end