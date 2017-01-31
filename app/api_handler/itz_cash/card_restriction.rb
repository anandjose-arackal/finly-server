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
    self.restriction_type = params[:channel_type_allowed]
    self.day_trans_limit = (params[:dailycount] > 0) ? params[:dailycount] : [params[:weeklycount], params[:monthlycount]].max.ceil
    self.day_amount_limit = (params[:dailyamount] > 0) ? params[:dailyamount] : [[:weeklyamount], params[:monthlyamount]].max.ceil
    self.week_trans_limit = (params[:weeklycount] > 0) ? params[:weeklycount] : [params[:dailycount]*7, params[:monthlyamount]].max.ceil
    self.week_amount_limit = (params[:weeklyamount] > 0) ? params[:weeklyamount] : [[:dailyamount]*7, params[:monthlyamount]].max.ceil
    self.month_trans_limit = (params[:monthlycount] > 0) ? params[:monthlycount] : [params[:dailycount]*32, params[:weeklycount]*5].max.ceil
    self.month_amount_limit = (params[:monthlyamount] > 0) ? params[:monthlyamount] : [[:dailyamount]*32, params[:weeklyamount]*5].max.ceil
  end

  def post_params
    {serialid: card.proxy, itzmodule: Constants::ItzCash::MODULE,
     limittype: params[:channel_type], allowed: restriction_type,
     dailycount: day_trans_limit, dailyamount: day_amount_limit,
     weeklycount: week_trans_limit, weeklyamount: week_amount_limit,
     monthlycount: month_trans_limit, monthlyamount: month_amount_limit}
  end

  def validate
    if params[:limits][:dailyamount] < 0 || params[:limits][:monthlycount] < 0 || params[:limits][:weeklyamount] < 0
      add_message :error, "Amount cannot be negative"
      return
    end
    if params[:limits][:dailycount] < 0 || params[:limits][:weeklycount] < 0 || params[:limits][:monthlycount] < 0
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
      self.description = :params[:description]
    end
  end

end