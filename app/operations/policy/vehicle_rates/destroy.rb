class Policy::VehicleRates::Destroy < BaseOperation
  attr_accessor :vehicle_rate

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Invalid request'
      return
    end
  end

  def init
    policy_presenter = Policy::Show.(user, params)
    unless policy_presenter.success?
      add_message :error, policy_presenter.messages[:error]
      return
    end
    policy = policy_presenter.policy
    self.vehicle_rate = policy.vehicle_rates.with_id(params[:id])&.first
  end

  def validate
    unless self.vehicle_rate.present?
      add_message :error, 'Vehicle Rate not found'
      return
    end
  end

  def process
    unless self.vehicle_rate.destroy
      add_message :error, self.vehicle_rate.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Added a new rate'
  end

  protected
  def create_params
    params&.require(:vehicle_rate).permit(:vehicle_name, {rate_attributes: [:value, :currency_id]}, :distance_unit_id)
  end

end