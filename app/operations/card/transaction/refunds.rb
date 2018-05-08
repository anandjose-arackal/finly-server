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
    ids = self.card.transactions.refunds.pluck(:id)
    self.card.transactions.credits.except_manual_credits_debits.each do |transaction|
      # i.e. if the transaction is a credit, and has the same reference id as a previous transaction that
      # is a debit, it should be refund more often than not
      if self.card.transactions.debits.find_by(reference_id: transaction.reference_id)
        ids << transaction.id
      end
    end
    self.transactions = self.card.transactions.with_id(ids)
  end

  def success
    params[:transactions] = self.transactions
    Card::Transaction::Refunds::RefundsPresenter.new(user, params, messages)
  end
end