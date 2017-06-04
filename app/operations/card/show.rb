class Card::Show < Card::Base
  attr_accessor :card

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:id).blank? and params&.dig(:card_id).blank?
      add_message :error, 'Card not found'
    end
  end

  def init
    cards = Card::Index.(user, params)&.cards rescue nil
    if cards.present?
      self.card = cards.find_by(id: (params[:id] or params[:card_id]))
    end
  end

  def validate
    unless self.card.present?
      add_message :error, 'Card not found'
    end
  end

  def success
    params[:card] = self.card
    Card::Show::SuccessPresenter.new(user, params, messages)
  end

  class Card::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :card, :configurable_restrictions, :restrictions

    def init
      self.card = params&.dig(:card)
      self.configurable_restrictions = self.card&.card_program.spend_restrictions
      self.restrictions = self.card&.card_restriction
    end
  end

end