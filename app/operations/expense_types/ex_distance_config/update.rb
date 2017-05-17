# operation that enables / disables as well as updates the respective rates for a distance and time expense
# parameters:
# type: '1' for distance expenses
# parent_type: 'policy' or 'company' based on the type
# parent_id: id of the policy to which this configuration belongs
# distance_expense_config: {
#                rate_per_km: rate per km of the distance expense
#                default_category_id: id of the default category that the expense will be added to
#                enabled: 0 or 1 depending on whether it's being enabled or disabled
#            }

class ExpenseTypes::ExDistanceConfig::Update < ExpenseTypes::Base

  attr_accessor :distance_config

  def authorized_user_types
    [:company_admin, :policy_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    policies = Policy::Index.(user, {view: 'admin'}).policies rescue []
    self.distance_config = policies.find_by(id: params[:policy_id])&.distance_expense_config
    self.update_params = distance_expense_config_params
  end

  def authorize
    unless distance_config
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def pre_process
    base_currency_id = distance_config.policy.base_currency_id
    if update_params[:rate_attributes]
      update_params[:rate_attributes][:currency_id] = base_currency_id
      update_params[:distance_unit_id] = PhysicalUnit.kilometre_id
      if distance_config.rate.present?
        update_params[:rate_attributes][:id] = distance_config.rate.id
      end
    end
  end

  def process
    unless distance_config.update(update_params)
      messages[:error] = distance_config.errors.full_messages
    end
  end

  def post_process
    distance_config.rate.update_currencies(Date.today)
  end

  private

  def distance_expense_config_params
    params.require(:distance_expense_config).permit(:default_category_id, :enabled, rate_attributes: [:value, :currency_id])
  end

end