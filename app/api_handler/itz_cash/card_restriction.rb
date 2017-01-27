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

  def post_params
    self.card = user.cards.first
    {serialid: card.proxy, itzmodule: Constants::ItzCash::MODULE,
     limittype: params[:channel_type], allowed: params[:channel_type_allowed],
     dailycount: params[:limits][:dailycount], dailyamount: params[:limits][:dailyamount],
     weeklycount: params[:limits][:weeklycount], weeklyamount:params[:limits][:weeklyamount],
     monthlycount: params[:limits][:monthlycount], monthlyamount: params[:limits][:monthlyamount]}
  end


end