class Card::Transaction::Create < BaseOperation

  attr_accessor :card, :card_owner, :type, :mode, :transaction

  class Card::Transaction::TransactionPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transaction

    def init
      self.transaction = params[:transaction]
    end

  end



  def initialize(params, messages={})
    self.params = params
    self.messages = messages
  end

  def init
    self.card = Card.find_by(proxy: params[:serial_id])
    self.user = self.card.user rescue nil
    self.type = params[:transaction_type]
    self.mode = params[:transaction_mode]
  end

  def authorize
    unless card and user
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    case type
      when "Debit"
        case mode
          when "POS"
            # create a transaction out of it
            self.transaction = CardTransaction.new(params)
            unless transaction.save
              messages[:error] = transaction.errors.full_messages
              return false
            end

            # create the associated card expense for this transaction
            @result = Expense::ExCard::Create.(transaction, card)
            unless @result.success?
              messages[:error] = @result.messages[:error]
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
            return true
          when "ATM"
            # create a transaction out of it
            self.transaction = CardTransaction.new(params)
            unless transaction.save
              messages[:error] = transaction.errors.full_messages
              return false
            end
            # add to cash in hand
            unless user.balance_sheet.add_cash_in_hand(params[:billing_amount_attributes][:value])
              messages[:error] = "Could not add credited amount to cash in hand. Try again"
              transaction.expensed = false
              transaction.error_message = @result.messages[:error]
              transaction.save
              return false
            end
          else
            # do nothing
        end
      when "Credit"
        self.transaction = CardTransaction.new(params)
        unless transaction.save
          messages[:error] = transaction.errors.full_messages
        end
        # gets added to user's card balance, so do nothing
      else
        # do nothing
    end
  end

  def post_process
    # send mailer regarding usage of card?
  end

  def success
    Card::Transaction::TransactionPresenter.new(user, {transaction: transaction}, messages)
  end

end