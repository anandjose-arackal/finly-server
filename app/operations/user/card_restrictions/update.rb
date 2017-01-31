class User::CardRestrictions::Update < User::Base

  attr_accessor :selected_user, :card_restriction, :update_params

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid input. Please try again"
    end
  end

  def init
    set_updating_params
    self.selected_user = user.company.users.find_by(id: params[:id])
    self.card_restriction = selected_user.card_restriction
    self.update_params = card_restriction_params
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

  def set_updating_params
    params[:restrictions][:card_limits_attributes] = []
    params[:restrictions][:limits].each do |index, limit|
      params[:restrictions][:card_limits_attributes] << {id: limit[:id], budget: limit[:budget].to_f, period_id: limit[:period_id], transactions: limit[:transactions]}
    end
  end

  def card_restriction_params
    params[:restrictions][:channel_online] = params[:restrictions][:channel_ecom]
    params.require(:restrictions).permit(:channel_atm, :channel_pos, :channel_online, :product_code_id, card_limits_attributes: [:id, :budget, :period_id, :transactions])
  end
end