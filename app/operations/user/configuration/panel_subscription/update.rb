class User::Configuration::PanelSubscription::Update < BaseOperation

  attr_accessor :selected_user, :panel_subscription

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = user.company.users.find_by(id: id)
    self.panel_subscription = selected_user.user_panel_subscription
  end

  def validate

  end

  def process
    unless panel_subscription.update(subscription_params)
      add_message :error, panel_subscription.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Updated subscription preferences successfully"
  end

  private

  def subscription_params
    params.require(:user_panel_config).permit(:disburse, :expense_management, :yes_bank_account_transfer)
  end

end