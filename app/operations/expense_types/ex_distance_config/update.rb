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
    case params[:parent_type]
      when 'company'
        self.distance_config = user.company.distance_expense_config
      when 'policy'
        policies = Policy::Index.(user, {view: 'policy_admin'}).policies rescue []
        self.distance_config = policies.find_from_id(params[:parent_id]).distance_expense_config rescue nil
      else
        self.distance_config = nil
    end
  end

  def authorize
    unless distance_config
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    unless distance_config.update(distance_expense_config_params)
      messages[:error] = distance_config.errors.full_messages
    end
  end

  private

  def distance_expense_config_params
    params.require(:distance_expense_config).permit(:rate_per_km, :default_category_id, :enabled)
  end

end