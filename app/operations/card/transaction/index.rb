class Card::Transaction::Index < BaseOperation

  attr_accessor :transactions

  class Card::Transaction::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    include HasScope

    has_scope :filter_refunds

    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
      self.transactions = apply_scopes(transactions, params)
    end

  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.transactions = user.card_transactions
  end

  def validate

  end

  def process

  end

  def authorize

  end

  def success
    params[:transactions] = transactions
    Card::Transaction::PaymentsPresenter.new(user, params, messages)
  end
end