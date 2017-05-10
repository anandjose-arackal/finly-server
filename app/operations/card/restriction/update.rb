class Card::Restriction::Update < User::Base

  attr_accessor :selected_user, :selected_card, :card_restriction, :update_params, :limit_types_enable, :limit_types_disable,
                :atm_limit_params, :atm_limits_present, :ecom_pos_limit_params, :ecom_pos_limits_present, :card_limits,
                :api_params, :invalid

  attr_accessor :selected_card, :selected_user,
                :atm_enabled, :ecom_pos_enabled


  def authorized_user_types
    [:company_admin, :manager, :finance_manager]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'Invalid input. Please try again'
      return
    end
    if params[:card_id].blank?
      add_message :error, 'Card not found'
    end
    if params[:user_id].blank? && params[:id].blank?
      add_message :error, 'User not found'
    end
  end

  def init
    # self.selected_user = user.company.users.find_by(id: params[:id])
    self.selected_user = User::Index.(user, params).team.with_id((params[:id] or params[:user_id])).first rescue nil
    return if selected_user.blank?
    self.selected_card = selected_user.cards.with_id(params[:card_id]).first
    return if selected_card.blank?
    self.card_restriction = selected_card.card_restriction
    self.card_limits = self.card_restriction.card_limits
    self.update_params = card_restriction_params
    self.atm_enabled = !!update_params[:channel_atm]
    self.ecom_pos_enabled = !!update_params[:channel_ecom_pos]
    self.atm_limit_params = set_atm_limit_params
    self.ecom_pos_limit_params = set_ecom_pos_limit_params
  end

  def validate
    unless selected_user
      add_message :error, 'User not found'
      return
    end
    if selected_card.blank?
      add_message :error, 'Card not found'
    end
  end

  def pre_process
    # setting the channel_atm and channel_ecom_pos flags here
    if update_params[:channel_atm].nil?
      update_params[:channel_atm] = nil
    end
    if update_params[:channel_ecom_pos].nil?
      update_params[:channel_ecom_pos] = nil
    end
    if update_params[:mcc_restriction_type].nil?
      update_params[:mcc_restriction_type] = nil
    end
  end

  def process
    # todo - handle API  calls to the ItzCash server to update the parameters on ItzCash's server
    api_presenter = invoke_limit_apis
    if api_presenter
      if card_restriction.update(update_params)
        atm_limit_params.each do |obj|
          obj.permit!
          limit = CardLimit.find(obj['id'] || obj[:id]) rescue nil
          next if limit.nil?
          limit.update(obj)
        end
        ecom_pos_limit_params.each do |obj|
          obj.permit!
          limit = CardLimit.find(obj['id'] || obj[:id]) rescue nil
          next if limit.nil?
          limit.update(obj)
        end
      else
        add_message :error, card_restriction.errors.full_messages
      end
    else
      add_message :error, "We're facing connectivity issues. Please try again after some time" if messages[:error].empty?
      # reset all card limits
      reset_card_limits
    end

  end

  def post_process
    add_message :success, 'Limits updated'
  end

  private

  def card_restriction_params
    params.require(:restrictions).permit(:mcc_group_id, :mcc_restriction_type, :channel_atm, :channel_ecom_pos, limits: [atm_limits: [:id, :transactions, :budget],
                                                                                                     ecom_pos_limits: [:id, :transactions, :budget]])
  end

  def set_atm_limit_params
    r = []
    card_restriction_params[:limits].each do |k, v|
      if k == 'atm_limits'
        v.each do |key, value|
          # setting the budget and transaction limit as nil if atm has been disabled
          value[:budget] = value[:transactions] = nil unless atm_enabled
          r << value
        end
      end
    end
    r
  end

  def set_ecom_pos_limit_params
    r = []
    card_restriction_params[:limits].each do |k, v|
      if k == 'ecom_pos_limits'
        v.each do |key, value|
          # setting budget and transaction limits as nil if ecom/pos has been disabled
          value[:budget] = value[:transactions] = nil unless ecom_pos_enabled
          r << value
        end
      end
    end
    r
  end

  def atm_limits_present?
    return false unless atm_enabled
    present = false
    update_params[:limits][:atm_limits].each do |key, value|
      if value[:budget].present? || value[:transactions].present?
        present = true
      end
    end
    present
  end

  def ecom_pos_limits_present?
    return false unless ecom_pos_enabled
    present = false
    update_params[:limits][:ecom_pos_limits].each do |key, value|
      if value[:budget].present? || value[:transactions].present?
        present = true
      end
    end
    present
  end


  def invoke_limit_apis
    # resetting the product code ID for the card
    api_params = {}
    api_params[:mcc_group_id] = card_restriction_params[:mcc_group_id]
    if card_restriction_params[:mcc_group_id].present?
      api_params[:mcc_restriction_type] = card_restriction_params[:mcc_restriction_type]
    else
      api_params[:mcc_restriction_type] = 'I'
    end
    # mcc_group_api = ItzCash::SetMccCode.(selected_user, api_params)
    # unless mcc_group_api.success?
    #   add_message :error, mcc_group_api.messages[:error]
    #   return false
    # end
    # Setting the atm restriction parameters
    if atm_enabled && atm_limits_present?
      daily_amount = atm_limit_params[0][:budget].to_i || 0
      daily_count = atm_limit_params[0][:transactions].to_i || 0
      weekly_amount = atm_limit_params[1][:budget].to_i || 0
      weekly_count = atm_limit_params[1][:transactions].to_i || 0
      monthly_amount = atm_limit_params[2][:budget].to_i || 0
      monthly_count = atm_limit_params[2][:transactions].to_i || 0
      api_params = {dailycount: daily_count, dailyamount: daily_amount,
                    weeklycount: weekly_count, weeklyamount: weekly_amount,
                    monthlycount: monthly_count, monthlyamount: monthly_amount,
                    channel_type: 'ATM', channel_type_allowed: 'Y'}
    elsif atm_enabled && !atm_limits_present?
      api_params = {dailycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, dailyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    weeklycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, weeklyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    monthlycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, monthlyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    channel_type: 'ATM', channel_type_allowed: 'I'}
    elsif !atm_enabled
      api_params = {dailycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, dailyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    weeklycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, weeklyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    monthlycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, monthlyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    channel_type: 'ATM', channel_type_allowed: 'N'}
    end
    restriction_api = ItzCash::CardRestriction.(selected_user, api_params)
    unless restriction_api.success?
      add_message :error, restriction_api.messages[:error]
      return false
    end
    # Setting the pos/atm restriction parameters
    if ecom_pos_enabled && ecom_pos_limits_present?
      daily_amount = ecom_pos_limit_params[0][:budget].to_i || 0
      daily_count = ecom_pos_limit_params[0][:transactions].to_i || 0
      weekly_amount = ecom_pos_limit_params[1][:budget].to_i || 0
      weekly_count = ecom_pos_limit_params[1][:transactions].to_i || 0
      monthly_amount = ecom_pos_limit_params[2][:budget].to_i || 0
      monthly_count = ecom_pos_limit_params[2][:transactions].to_i || 0
      api_params = {dailycount: daily_count, dailyamount: daily_amount,
                    weeklycount: weekly_count, weeklyamount: weekly_amount,
                    monthlycount: monthly_count, monthlyamount: monthly_amount,
                    channel_type: 'POS', channel_type_allowed: 'Y'}
    elsif ecom_pos_enabled && !ecom_pos_limits_present?
      api_params = {dailycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, dailyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    weeklycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, weeklyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    monthlycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, monthlyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    channel_type: 'POS', channel_type_allowed: 'I'}
    elsif !ecom_pos_enabled
      api_params = {dailycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, dailyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    weeklycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, weeklyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    monthlycount: Constants::ItzCash::RESTRICTION_TRANS_CONSTANT, monthlyamount: Constants::ItzCash::RESTRICTION_BUDGET_CONSTANT,
                    channel_type: 'POS', channel_type_allowed: 'N'}
    end
    restriction_api = ItzCash::CardRestriction.(selected_user, api_params)
    unless restriction_api.success?
      add_message :error, restriction_api.messages[:error]
      return false
    end
    update_params.delete(:limits)
    true
  end

  def reset_card_limits

  end

end