# Operation that enables / disables per diem expenses for a company or policy
# params:
# per_diem_enabled: 1 or 0 depending on enabled or disabled
# configurable_type: 'policy' or 'company' depending on what type it is
# policy_id: id of the policy under which that per_diem is enabled is being updated

class ExpenseTypes::PerDiem::Enable < ExpenseTypes::PerDiem::Base

  def authorized_user_types
    [:policy_admin, :company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    case params[:configurable_type]
      when 'company'
        self.configurable_object = user.company
      when 'policy'
        self.configurable_object = user.company.policies.find_from_id(params[:policy_id])
      else
        # do nothing
    end
  end

  def authorize
    super()
  end

  def process

  end

  def success

  end

  private

  def enable_per_diem_params
    params.permit(:per_diem_enabled, :configurable_type, :policy_id)
  end
end