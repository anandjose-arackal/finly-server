class User::PrepaidCard::Base < BaseOperation
  attr_accessor :card

  STATUS = {block: 0, unblock: 1}

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    self.params = {} if self.params.blank?

    self.card = params[:card]
    if self.card.blank? and params[:card_id].present?
      card_id = params[:card_id]
      cards = Card::Index.(user, params)
      self.card = cards.cards.find_by(id: card_id)
    end
  end

  def validate
    if self.card.blank?
      add_message :error, 'Card not found'
    end
  end

end