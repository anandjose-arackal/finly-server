class Card::Transaction::Refunds < BaseOperation

  attr_accessor :transactions, :card

  class Card::Transaction::Refunds::RefundsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
    end

  end

  def init
    self.card = current_user.cards.first
  end

  def validate
    if self.card.blank?
      add_message :error, "This user doesn't have any cards associated with them"
      return
    end
  end

  def process
    ids = self.card.transactions.refunds
    
  end


end