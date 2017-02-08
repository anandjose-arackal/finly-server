# action that updates the card balance history after a particular messages queue entry

class Card::Balance::Update < BaseOperation

  attr_accessor :history

  class Card::Balance::Update::HistoryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance_history

    def init
      self.balance_history = params[:history]
    end
  end

  def initialize(params, messages = {})
    self.params = params
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:card_proxy])
    if card
      self.balance_id = card.card_balance_history.amount_id
    end
  end

  def validate
    unless card
      add_message :error, "Card not found"
    end
  end

  def process
    self.history = card.card_balance_history.build(history_update_params)
    unless history.save
      add_message :error, card.errors.full_messages
    end
  end

  def success
    params[:history] = history
  end

  private

  def history_update_params
    p = params.permit(:timestamp, amount_attributes: [:value, :currency_id])
    p[:amount_attributes][:id] = balance_id
    p.permit!
  end

end