# action that updates the card balance history after a particular messages queue entry, and also updates the currenct
# card's balance

class Card::Balance::Update < BaseOperation

  attr_accessor :history, :card, :balance

  class Card::Balance::Update::HistoryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance_history

    def init
      self.balance_history = params[:history]
    end
  end

  def initialize(params, messages = {})
    self.params = (ActionController::Parameters.new(params) or {})
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:card_proxy])
    self.balance = params[:amount_attributes][:value]
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
    card.card_balance.update_attributes(value: balance)
  end

  def success
    params[:history] = history
    Card::Balance::Update::HistoryPresenter.new(user, params, messages)
  end

  private

  def history_update_params
    params.permit(:timestamp, amount_attributes: [:value, :currency_id])
  end

end