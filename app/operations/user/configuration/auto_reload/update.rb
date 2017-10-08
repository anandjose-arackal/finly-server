class User::Configuration::AutoReload::Update < BaseOperation

  attr_accessor :reload_config, :update_params, :selected_user, :source_account_type

  def authorized_user_types
    [:admin, :finance_manager, :manager, :employee]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:auto_reload_config].blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User::Team::Index.(user, params).with_id(id).first rescue nil
    # if it's not someone in the user's team, it's the user themselves
    self.selected_user = user if selected_user.blank?
    self.reload_config = selected_user.auto_reload_config
    self.update_params = auto_reload_config_params
    self.source_account_type = update_params[:source_account_type]
    # setting the source account based on the sent params
    self.update_params[:source_account] = retrieve_source_account
  end

  def validate
    if update_params[:target_balance_attributes][:value].to_f <= 0 && update_params[:enabled] == '1'
      add_message :error, "Target balance cannot be less than or equal to 0"
      return
    end
    if update_params[:threshold_balance_attributes][:value].to_f <= 0 && update_params[:enabled] == '1'
      add_message :error, "Threshold balance cannot be less than or equal to 0"
      return
    end
  end

  def pre_process
    # ensuring that the auto reload configuration is always in Rupees
    update_params[:target_balance_attributes][:currency_id] = "1"
    update_params[:threshold_balance_attributes][:currency_id] = "1"
    if update_params[:enabled] == '0'
      update_params.delete(:target_balance_attributes)
      update_params.delete(:threshold_balance_attributes)
    end
    # removing the receiving account type attribute from front end
    update_params.delete(:source_account_type)

    update_params[:application] = RequestStore.store[:current_app]
  end



  def process
    unless reload_config.update(update_params)
      add_message :error, reload_config.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Configuration updated"
  end

  private

  def auto_reload_config_params
    # here default currency id will be rupee because card reloads can only happen in INR
    params.require(:auto_reload_config).permit(:enabled, :source_account_type, target_balance_attributes: [:value, :currency_id], threshold_balance_attributes: [:value, :currency_id])
  end

  def retrieve_source_account
    case self.source_account_type
      when '1', 1
        return user.company.itz_cash_company_account
      when '2', 2
        return selected_user.wallet
      else
        # do nothing?
    end
  end
end