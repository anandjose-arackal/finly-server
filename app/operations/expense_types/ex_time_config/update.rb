# operation that enables / disables as well as updates the respective rates for a time and time expense
# parameters:
# type = '2', for time expense
# parent_type: 'policy' or 'company' based on the type
# parent_id: id of the policy to which this configuration belongs
# time_expense_config: {
#                rate_per_km: rate per km of the time expense
#                default_category_id: id of the default category that the expense will be added to
#                enabled: 0 or 1 depending on whether it's being enabled or disabled
#            }

class ExpenseTypes::ExTimeConfig::Update < ExpenseTypes::Base

  attr_accessor :time_config

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
        self.time_config = user.company.time_expense_config
      when 'policy'
        policies = Policy::Index.(user, {view: 'admin'}).policies rescue []
        self.time_config = policies.find_from_id(params[:parent_id]).time_expense_config rescue nil
      else
        self.time_config = nil
    end
    self.update_params = time_expense_config_params
  end

  def authorize
    unless time_config
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def pre_process
    base_currency_id = time_config.parent.base_currency_id
    update_params[:rate_attributes][:currency_id] = base_currency_id
  end

  def process
    unless time_config.update(update_params)
      messages[:error] = time_config.errors.full_messages
    end
  end

  private

  def time_expense_config_params
    params.require(:time_expense_config).permit(:default_category_id, :enabled, rate_attributes: [:value, :currency_id])
  end

end