# Used to create users without invitation
class User::CreateWoPassword < Admin::Users::Create
  def pre_validate
    # Overriding admin user create operation's behaviour
    params[:user][:password] = rand(36**8).to_s(36)
  end

  def configure_disburse
    # from disburse panel subscribing users to only disburse
    new_user_params[:user_panel_subscription_attributes] = {
        expense_management: false,
        disburse: true
    }
    new_user_params.permit!
  end
end