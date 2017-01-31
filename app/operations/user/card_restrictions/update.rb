class User::CardRestrictions::Update < User::Base

  attr_accessor :selected_user, :card_restriction, :update_params, :limit_types_enable, :limit_types_disable, :card_limit_update_params, :card_limits

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid input. Please try again"
    end
  end

  def init
    self.update_params = card_restriction_params
    self.selected_user = user.company.users.find_by(id: params[:id])
    self.card_limits = selected_user.card_restriction.card_limits
    self.card_limit_update_params = set_limit_params
    # set_updating_params
    # self.limit_types_enable = []
    # self.limit_types_disable = []
    # set_updating_params
    # set_limit_types
    # self.selected_user = user.company.users.find_by(id: params[:id])
    # self.card_restriction = selected_user.card_restriction
    # self.update_params = card_restriction_params
  end

  def validate
    unless selected_user
      add_message :error, "User not found"
    end
  end

  def process

    unless card_restriction.update(update_params)
      add_message :error, card_restriction.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Limits updated"
  end

  private

  def card_restriction_params
    params[:restrictions][:channel_online] = params[:restrictions][:channel_ecom]
    params.require(:restrictions).permit(:product_code_id, channel_atm: [:enabled], channel_ecom_pos: [:enabled], limits: [atm_limits: [:id, :transactions, :budget],
                                                                                                                          ecom_pos_limits: [:id, :transactions, :budget]])
  end

  def set_limit_types
    if params[:channel_atm][:enabled]
      self.limit_types_enable << :atm
    else
      self.limit_types_disable << :atm
    end
    if params[:channel_ecom_pos][:enabled]
      self.limit_types_enable << :pos # because pos and ecom have a combined API
    else
      self.limit_types_disable << :pos
    end
  end

  def set_limit_params
    r = []
    card_restriction_params[:limits].each do |k, v|
      v.each do |key, value|
        r << value
      end
    end
    r
  end

  # method that parses the input parameters and sets the update parameters according to the model
  def set_updating_params
    self.update_params.each do |k, v|
      if v[:enabled] == '1'

      end
    end
  end
end