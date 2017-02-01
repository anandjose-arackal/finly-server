# API to set card limits on the Itzcash cards

class ItzCash::CardRestriction < ItzCash::Base

  attr_accessor :card, :day_trans_limit, :day_amount_limit, :week_trans_limit, :week_amount_limit, :month_trans_limit, :month_amount_limit,
                :restriction_type

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless user.cards.present?
      add_message :error, 'A card has not been assigned to the user'
    end
  end

  def env_key
    'itzcash_card_restriction'
  end

  def init
    super()
    self.card = user.cards.first
    self.restriction_type = params[:channel_type_allowed] # will always contain Y/N/I
    self.day_trans_limit = (params[:dailycount] > 0) ? params[:dailycount] : [params[:weeklycount], params[:monthlycount]].max.ceil
    self.day_amount_limit = (params[:dailyamount] > 0) ? params[:dailyamount] : [params[:weeklyamount], params[:monthlyamount]].max.ceil
    self.week_trans_limit = (params[:weeklycount] > 0) ? params[:weeklycount] : [params[:dailycount].to_i*7, params[:monthlyamount]].max.ceil
    self.week_amount_limit = (params[:weeklyamount] > 0) ? params[:weeklyamount] : [params[:dailyamount].to_i*7, params[:monthlyamount]].max.ceil
    self.month_trans_limit = (params[:monthlycount] > 0) ? params[:monthlycount] : [params[:dailycount].to_i*32, params[:weeklycount].to_i*5].max.ceil
    self.month_amount_limit = (params[:monthlyamount] > 0) ? params[:monthlyamount] : [params[:dailyamount].to_i*32, params[:weeklyamount].to_i*5].max.ceil
    post_initialize # this sets the limits to arbitrarily high values if they're not present
  end

  def post_params
    {serialid: card.proxy, itzmodule: Constants::ItzCash::MODULE,
     limittype: params[:channel_type], allowed: restriction_type,
     dailycount: day_trans_limit, dailyamount: day_amount_limit,
     weeklycount: week_trans_limit, weeklyamount: week_amount_limit,
     monthlycount: month_trans_limit, monthlyamount: month_amount_limit}
  end

  def validate
    if params[:dailyamount] < 0 || params[:monthlycount] < 0 || params[:weeklyamount] < 0
      add_message :error, "Amount cannot be negative"
      return
    end
    if params[:dailycount] < 0 || params[:weeklycount] < 0 || params[:monthlycount] < 0
      add_message :error, "Number of transactions can not be negative"
    end
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:limit_type] = parsed_response[2]
    params[:description] = parsed_response[3]
    ItzCash::CardRestriction::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::CardRestriction::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :limit_type, :description

    def init
      self.response_code = params[:response_code]
      self.serial_id = params[:serial_id]
      self.limit_type = params[:limit_type]
      self.description = params[:description]
    end
  end

  private

  def post_initialize
    self.day_trans_limit = Constants::ItzCash::RESTRICTION_CONSTANT if day_trans_limit == 0
    self.day_amount_limit = Constants::ItzCash::RESTRICTION_CONSTANT if day_amount_limit == 0
    self.week_trans_limit = Constants::ItzCash::RESTRICTION_CONSTANT if week_trans_limit == 0
    self.week_amount_limit = Constants::ItzCash::RESTRICTION_CONSTANT if week_amount_limit == 0
    self.month_trans_limit = Constants::ItzCash::RESTRICTION_CONSTANT if month_trans_limit == 0
    self.month_amount_limit = Constants::ItzCash::RESTRICTION_CONSTANT if month_amount_limit == 0
  end

end