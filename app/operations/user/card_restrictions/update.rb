class User::CardRestrictions::Update < User::Base

  attr_accessor :selected_user, :dummy_restriction

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
    self.dummy_restriction = selected_user.dummy_restriction
    self.update_params = card_restriction_params
  end

  def validate
    unless selected_user

    end
  end

  def process
    unless dummy_restriction.update(update_params)
      add_message :error, dummy_restriction.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Limits updated"
  end

  private

  def set_updating_params
    params[:restrictions][:card_limits_attributes] = []
    params[:restrictions][:limits].each do |limit|
      params[:restrictions][:card_limits_attributes] << {amount: limit[:amount], period_id: limit[:period_id], transactions: limit[:transactions]}
    end
  end

  def card_restriction_params
    params.require(:restrictions).permit(:channel_atm, :channel_pos, :channel_ecom, :product_code_id, card_limits_attributes: [:id, :amount, :period_id, :transactions])
  end
end