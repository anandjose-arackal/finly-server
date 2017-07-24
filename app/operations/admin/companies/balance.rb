class Admin::Companies::Balance < Company::VirtualAccount::Balance

  def user_model
    AdminUser
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params[:company].blank?
      add_message :error, "No company passed"
    end
  end

  def authorized_user_types
    [:admin]
  end

  def validate
    unless company.d_code_assigned?
      add_message :error, 'Company has not been configured to maintain balance'
    end
  end

  def init
    # self.company = user.company ||
    self.company = params[:company]

    self.total_wallet_balance = company.account.wallet_balance.value
    self.scheduled_payment_orders_balance = company.payment_orders.scheduled.total_amount_requested
  end
end
