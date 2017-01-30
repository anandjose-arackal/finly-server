# API to set card limits on the Itzcash cards

class ItzCash::CardRestriction < ItzCash::Base

  attr_accessor :card

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
  end

  def post_params
    {serialid: card.proxy, itzmodule: Constants::ItzCash::MODULE,
     limittype: params[:channel_type], allowed: params[:channel_type_allowed],
     dailycount: params[:limits][:dailycount], dailyamount: params[:limits][:dailyamount],
     weeklycount: params[:limits][:weeklycount], weeklyamount:params[:limits][:weeklyamount],
     monthlycount: params[:limits][:monthlycount], monthlyamount: params[:limits][:monthlyamount]}
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
    
  end

  class ItzCash::CardRestriction::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

  end

end