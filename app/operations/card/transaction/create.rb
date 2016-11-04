class Card::Transaction::Create < BaseOperation

  attr_accessor :card, :card_owner

  def initialize(params, messages)
    self.params = params
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:serial_id])
    self.user = self.card.user rescue nil
  end

  def authorize

  end

  def process

  end

end