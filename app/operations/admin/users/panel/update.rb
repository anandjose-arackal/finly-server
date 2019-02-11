class Admin::Users::Panel::Update < Admin::Users::Base

  attr_accessor :selected_user, :panel_subscription

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
    self.panel_subscription = selected_user.user_panel_subscription
  end

  def validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
    # if subscription_params[:yes_bank_account_transfer] == '1'
    #   unless selected_user.admin? || selected_user.finance_manager?
    #     add_message :error, "Vendor Payments is only available for Admins and Finance Managers as of now"
    #     return
    #   end
    # end
  end

  def process
    p subscription_params
    unless panel_subscription.update(subscription_params)
      add_message :error, panel_subscription.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Updated subscription preferences successfully"
  end

  private

  def subscription_params
    params.require(:user_panel_config).permit(:disburse, :expense_management, :yes_bank_account_transfer, :invoicing_system, :travel_request)
  end
end