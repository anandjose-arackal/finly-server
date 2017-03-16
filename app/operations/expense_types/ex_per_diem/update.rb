# operation that enables / disables as well as updates the respective rates for a per_diem and time expense
# parameters:
# type '3' for per diem
# parent_type: 'policy' or 'company' based on the type
# parent_id: id of the policy to which this configuration belongs
# per_diem_expense_config: {
#                rate_per_km: rate per km of the per_diem expense
#                default_category_id: id of the default category that the expense will be added to
#                enabled: 0 or 1 depending on whether it's being enabled or disabled
#            }

class ExpenseTypes::ExPerDiem::Update < ExpenseTypes::PerDiem::Base

  attr_accessor :per_diem_config

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    case params[:parent_type]
      when 'company'
        self.per_diem_config = user.company.per_diem_expense_config
      when 'policy'
        policies = Policy::Index.(user, {view: 'policy_admin'}).policies rescue []
        self.per_diem_config = policies.find_from_id(params[:parent_id]).per_diem_expense_config rescue nil
      else
        self.per_diem_config = nil
    end
  end

  def authorize
    unless per_diem_config
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    unless per_diem_config.update(per_diem_expense_config_params)
      messages[:error] = per_diem_config.errors.full_messages
    end
  end

  private

  def per_diem_expense_config_params
    params.require(:per_diem_expense_config).permit(:enabled)
  end

end

